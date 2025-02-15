import android.content.Context
import android.net.Uri
import androidx.compose.runtime.Composable
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.GlanceTheme
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.currentState
import androidx.glance.layout.Alignment
import androidx.glance.layout.Column
import androidx.glance.layout.Row
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxHeight
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.height
import androidx.glance.layout.padding
import androidx.glance.state.GlanceStateDefinition
import androidx.glance.text.FontFamily
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import com.google.gson.FieldNamingPolicy
import com.google.gson.GsonBuilder
import dev.solsynth.solian.MainActivity
import dev.solsynth.solian.data.InstantAdapter
import dev.solsynth.solian.data.SolarCheckInRecord
import es.antonborri.home_widget.actionStartActivity
import java.time.Instant
import java.time.LocalDate
import java.time.OffsetDateTime
import java.time.ZoneId
import java.time.format.DateTimeFormatter

class CheckInWidget : GlanceAppWidget() {
    override val stateDefinition: GlanceStateDefinition<*>?
        get() = HomeWidgetGlanceStateDefinition()

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            GlanceTheme {
                GlanceContent(context, currentState())
            }
        }
    }

    @Composable
    private fun GlanceContent(context: Context, currentState: HomeWidgetGlanceState) {
        val gson =
            GsonBuilder()
                .setFieldNamingPolicy(FieldNamingPolicy.LOWER_CASE_WITH_UNDERSCORES)
                .registerTypeAdapter(Instant::class.java, InstantAdapter())
                .create()
        val resultTierSymbols = listOf("Bad", "Poor", "Medium", "Good", "Great")

        val prefs = currentState.preferences
        val checkInRaw: String? = prefs.getString("pas_check_in_record", null)

        val checkIn: SolarCheckInRecord? =
            checkInRaw?.let { checkInRaw ->
                gson.fromJson(checkInRaw, SolarCheckInRecord::class.java)
            } ?: null;

        Column(
            modifier = GlanceModifier
                .fillMaxWidth()
                .fillMaxHeight()
                .background(GlanceTheme.colors.widgetBackground)
                .padding(16.dp)
                .clickable(
                    onClick = actionStartActivity<MainActivity>(
                        context,
                        Uri.parse("https://sn.solsynth.dev")
                    )
                )
        ) {
            if (checkIn != null) {
                val dateFormatter = DateTimeFormatter.ofPattern("EEE, MM/dd")

                val checkDate = checkIn.createdAt.atZone(ZoneId.of("UTC")).toLocalDate()
                val currentDate = LocalDate.now()
                if (checkDate.isEqual(currentDate)) {
                    Column {
                        Text(
                            text = resultTierSymbols[checkIn.resultTier],
                            style = TextStyle(
                                fontSize = 17.sp,
                                color = GlanceTheme.colors.onSurface
                            )
                        )
                        Text(
                            text = "+${checkIn.resultExperience} EXP",
                            style = TextStyle(
                                fontSize = 13.sp,
                                fontFamily = FontFamily.Monospace,
                                color = GlanceTheme.colors.onSurface
                            )
                        )
                    }
                    Spacer(modifier = GlanceModifier.height(8.dp))
                    Row(horizontalAlignment = Alignment.CenterHorizontally) {
                        Text(
                            text = OffsetDateTime.ofInstant(
                                checkIn.createdAt,
                                ZoneId.systemDefault()
                            )
                                .format(dateFormatter),
                            style = TextStyle(
                                fontSize = 11.sp,
                                color = GlanceTheme.colors.onSurface
                            )
                        )
                    }

                    return@Column;
                }
            }

            Text(
                text = "You haven't divined today",
                style = TextStyle(fontSize = 15.sp, color = GlanceTheme.colors.onSurface)
            )
        }
    }
}
