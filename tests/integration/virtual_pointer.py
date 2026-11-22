"""Minimal test-only wlr virtual pointer, restricted to an owned private socket."""
import ctypes as c
from pathlib import Path
import time


class Interface(c.Structure):
    pass


class Message(c.Structure):
    _fields_ = [("name", c.c_char_p), ("signature", c.c_char_p),
                ("types", c.POINTER(c.POINTER(Interface)))]


Interface._fields_ = [("name", c.c_char_p), ("version", c.c_int),
                     ("method_count", c.c_int), ("methods", c.POINTER(Message)),
                     ("event_count", c.c_int), ("events", c.POINTER(Message))]


class VirtualPointer:
    def __init__(self, socket_path, private_root):
        socket_path = Path(socket_path).resolve()
        private_root = Path(private_root).resolve()
        if not private_root.name.startswith("dot-shell-") or not socket_path.is_relative_to(private_root):
            raise ValueError("Virtual pointer must use the owned temporary compositor socket")
        self.lib = c.CDLL("libwayland-client.so.0")
        self.display = None
        self.lib.wl_display_connect.argtypes = [c.c_char_p]
        self.lib.wl_display_connect.restype = c.c_void_p
        self.lib.wl_display_disconnect.argtypes = [c.c_void_p]
        self.lib.wl_display_roundtrip.argtypes = [c.c_void_p]
        self.lib.wl_display_roundtrip.restype = c.c_int
        self.lib.wl_proxy_marshal_flags.argtypes = [c.c_void_p, c.c_uint,
            c.POINTER(Interface), c.c_uint, c.c_uint]
        self.lib.wl_proxy_marshal_flags.restype = c.c_void_p
        self.lib.wl_proxy_add_listener.argtypes = [c.c_void_p, c.c_void_p, c.c_void_p]
        try:
            self.display = self.lib.wl_display_connect(str(socket_path).encode())
            if not self.display:
                raise RuntimeError("Cannot connect to private Wayland socket")
            registry_type = Interface.in_dll(self.lib, "wl_registry_interface")
            registry = self.lib.wl_proxy_marshal_flags(self.display, 1, c.byref(registry_type), 1, 0, c.c_void_p())
            globals_found = {}
            global_callback = c.CFUNCTYPE(None, c.c_void_p, c.c_void_p, c.c_uint, c.c_char_p, c.c_uint)
            remove_callback = c.CFUNCTYPE(None, c.c_void_p, c.c_void_p, c.c_uint)
            self.on_global = global_callback(lambda data, obj, name, interface, version:
                globals_found.update({interface.decode(): (name, version)}))
            self.on_remove = remove_callback(lambda data, obj, name: None)
            self.listener = (c.c_void_p * 2)(c.cast(self.on_global, c.c_void_p), c.cast(self.on_remove, c.c_void_p))
            self.lib.wl_proxy_add_listener(registry, self.listener, None)
            self.roundtrip()
            name, _ = globals_found["zwlr_virtual_pointer_manager_v1"]
            # ABI request order/signatures from the wlr virtual-pointer protocol.
            self.pointer_methods = (Message * 9)(*[Message(name, signature, None) for name, signature in (
                (b"motion", b"uff"), (b"motion_absolute", b"uuuuu"),
                (b"button", b"uuu"), (b"axis", b"uuf"), (b"frame", b""),
                (b"axis_source", b"u"), (b"axis_stop", b"uu"),
                (b"axis_discrete", b"uufi"), (b"destroy", b""))])
            self.pointer_type = Interface(b"zwlr_virtual_pointer_v1", 1, 9, self.pointer_methods, 0, None)
            self.seat_type = Interface.in_dll(self.lib, "wl_seat_interface")
            self.create_types = (c.POINTER(Interface) * 2)(c.pointer(self.seat_type), c.pointer(self.pointer_type))
            self.manager_methods = (Message * 2)(Message(b"create_virtual_pointer", b"?on", self.create_types),
                                                 Message(b"destroy", b"", None))
            self.manager_type = Interface(b"zwlr_virtual_pointer_manager_v1", 1, 2, self.manager_methods, 0, None)
            manager = self.lib.wl_proxy_marshal_flags(registry, 0, c.byref(self.manager_type), 1, 0,
                c.c_uint(name), c.c_char_p(self.manager_type.name), c.c_uint(1), c.c_void_p())
            self.pointer = self.lib.wl_proxy_marshal_flags(manager, 0, c.byref(self.pointer_type), 1, 0,
                                                          c.c_void_p(), c.c_void_p())
            self.roundtrip()
        except Exception:
            self.close()
            raise

    def roundtrip(self):
        if self.lib.wl_display_roundtrip(self.display) < 0:
            raise RuntimeError("Private Wayland connection failed")

    def move(self, x, y, width, height):
        if not (0 <= x < width and 0 <= y < height):
            raise ValueError("Pointer coordinates must be inside the private output")
        timestamp = int(time.monotonic() * 1000) & 0xffffffff
        self.lib.wl_proxy_marshal_flags(self.pointer, 1, None, 1, 0,
            c.c_uint(timestamp), c.c_uint(x), c.c_uint(y), c.c_uint(width), c.c_uint(height))
        self.lib.wl_proxy_marshal_flags(self.pointer, 4, None, 1, 0)
        self.roundtrip()

    def close(self):
        if self.display:
            self.lib.wl_display_disconnect(self.display)
            self.display = None

    def __enter__(self):
        return self

    def __exit__(self, *args):
        self.close()
