#!/usr/bin/env python3
import pyglet

class Tablet():
    
    def __init__(self, name):
        self.name = name
        self.pen_state = {
            "x": 0.,
            "y": 0.,
            "pressure": 0.,
            "detected": False,
            "touched": False,
            "stylus_1": False,
            "stylus_2": False,
        }
        self.pad_state = {
            "pad_0": False,
            "pad_1": False,
            "pad_2": False,
            "pad_3": False,
        }
        
        # Functions registered by external code
        self._callbacks = []

    def add_callback(self, callback):
        self._callbacks.append(callback)

    def _state_changed(self):
        # Send a copy so external code cannot accidentally
        # modify the Tablet's internal state.
        state = {
            "pen": self.pen_state.copy(),
            "pad": self.pad_state.copy(),
        }
        for callback in self._callbacks:
            callback(state)


    def watch_control(self, device, control):
        @control.event
        def on_change(value):
            # print(f'{device!r}: {control!r}.on_change({value!r})')            
            # ---
            raw_name = control.raw_name
            if raw_name == "Axe X":
                self.pen_state["x"] = int(value)
            if raw_name == "Axe Y":
                self.pen_state["y"] = int(value)
            if raw_name == "Pression sur la pointe":
                self.pen_state["pressure"] = int(value)
            if raw_name == "À portée":
                self.pen_state["detected"] = bool(value)
            print(self.pen_state)
            # ---
            self._state_changed()

        if isinstance(control, pyglet.input.base.Button):
            @control.event
            def on_press():
                print(f"{device!r}: {control!r}.on_press()")
                # ---
                if control.raw_name == "Interrupteur de pointe":
                    self.pen_state["touched"] = True
                # ---
                self._state_changed()

            @control.event
            def on_release():
                print(f'{device!r}: {control!r}.on_release()')
                # ---
                if control.raw_name == "Interrupteur de pointe":
                    self.pen_state["touched"] = False
                # ---
                self._state_changed()


    def connect(self):
        devices = pyglet.input.get_devices()
        for device in devices:
            if device.name == self.name:
                try:
                    device.open()
                    print('Successfully connected to device')
                    for control in device.get_controls():
                        self.watch_control(device, control)
                except pyglet.input.DeviceException:
                    print('Failed to connect to device.')

if __name__ == "__main__":
    tab = Tablet("Wacom Tablet")
    tab.connect()
    pyglet.app.run()
