import os
import sys

def load_plugins():
    plugins_dir = os.path.join(sys.path[0], 'plugins')
    if not os.path.exists(plugins_dir):
        print(f"Plugins directory not found: {plugins_dir}")
        return

    for filename in os.listdir(plugins_dir):
        if filename.endswith('.py'):
            module_name = filename[:-3]
            try:
                __import__(module_name)
                print(f"Imported plugin: {module_name}")
            except Exception as e:
                print(f"Failed to import plugin {module_name}: {e}")
