package io.wazo.callkeep.utils;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.Iterator;

public class MapUtils {

    public static ConstraintsMap convertJsonToMap(JSONObject jsonObject) throws JSONException {
        ConstraintsMap map = new ConstraintsMap();

        Iterator<String> iterator = jsonObject.keys();
        while (iterator.hasNext()) {
            String key = iterator.next();
            Object value = jsonObject.get(key);
            if (value instanceof JSONObject) {
                map.putMap(key, convertJsonToMap((JSONObject) value).toMap());
            } else if (value instanceof  Boolean) {
                map.putBoolean(key, (Boolean) value);
            } else if (value instanceof  Integer) {
                map.putInt(key, (Integer) value);
            } else if (value instanceof  Double) {
                map.putDouble(key, (Double) value);
            } else if (value instanceof String)  {
                map.putString(key, (String) value);
            } else {
                map.putString(key, value.toString());
            }
        }
        return map;
    }

    public static JSONObject convertMapToJson(ConstraintsMap readableMap) throws JSONException {
        JSONObject object = new JSONObject();
        for (String key : readableMap.toMap().keySet()) {
            switch (readableMap.getType(key)) {
                case Null:
                    object.put(key, JSONObject.NULL);
                    break;
                case Boolean:
                    object.put(key, readableMap.getBoolean(key));
                    break;
                case Integer:
                    object.put(key, readableMap.getInt(key));
                    break;
                case Double:
                    object.put(key, readableMap.getDouble(key));
                    break;
                case String:
                    object.put(key, readableMap.getString(key));
                    break;
                case Map:
                    object.put(key, convertMapToJson(readableMap.getMap(key)));
                    break;
            }
        }
        return object;
    }
}