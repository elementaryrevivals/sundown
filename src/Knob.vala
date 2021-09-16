/*-
 * Copyright (c) 2021-2022 Subhadeep Jasu <subhajasu@gmail.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License 
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 *
 * Authored by: Subhadeep Jasu <subhajasu@gmail.com>
 */

public class Knob : Gtk.Overlay {
    public string tooltip;
    public bool dragging;
    private double dragging_direction_x;
    private double dragging_direction_y;
    bool locked;

    public double value = 27;
    public int drag_force = 0;
    protected Gtk.Box knob_socket_graphic;
    protected Gtk.Box knob_cover;
    protected Gtk.Box knob_background;
    protected Gtk.Box knob_rim;
    protected Gtk.Fixed fixed;
    protected int center;

    private Gtk.Label knob_label_dark;
    private Gtk.Label knob_label_light;

    protected const double RADIUS = 20;

    public signal void change_value (double value);

    public Knob () {
        center = 42;
        knob_socket_graphic = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        knob_socket_graphic.width_request = 20;
        knob_socket_graphic.height_request = 20;
        knob_socket_graphic.get_style_context ().add_class ("knob-socket-graphic");

        knob_cover = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        knob_cover.get_style_context ().add_class ("knob-cover-graphic");
        knob_cover.halign = Gtk.Align.START;
        knob_cover.valign = Gtk.Align.START;
        knob_cover.margin = 14;
        knob_cover.width_request = 100;
        knob_cover.height_request = 100;

        fixed = new Gtk.Fixed ();
        fixed.halign = Gtk.Align.START;
        fixed.valign = Gtk.Align.START;
        fixed.width_request = 100;
        fixed.height_request = 100;
        fixed.margin = 14;
        double px = RADIUS * GLib.Math.cos (value / Math.PI);
        double py = RADIUS * GLib.Math.sin (value / Math.PI);
        fixed.put (knob_socket_graphic, (int)(px + center), (int)(py + center));

        knob_background = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        knob_background.get_style_context ().add_class ("knob-meter-graphic");
        knob_background.halign = Gtk.Align.START;
        knob_background.valign = Gtk.Align.START;
        knob_background.width_request = 128;
        knob_background.height_request = 128;

        knob_label_dark = new Gtk.Label (_("DARK"));
        knob_label_dark.halign = Gtk.Align.START;
        knob_label_dark.valign = Gtk.Align.END;
        knob_label_dark.get_style_context ().add_class ("knob-meter-label");

        knob_label_light = new Gtk.Label (_("LIGHT"));
        knob_label_light.halign = Gtk.Align.END;
        knob_label_light.valign = Gtk.Align.END;
        knob_label_light.get_style_context ().add_class ("knob-meter-label");

        knob_background.pack_start (knob_label_dark, true);
        knob_background.pack_end (knob_label_light, true);

        knob_rim = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        knob_rim.get_style_context ().add_class ("knob-rim");
        knob_rim.halign = Gtk.Align.START;
        knob_rim.valign = Gtk.Align.START;
        knob_rim.margin = 14;
        knob_rim.width_request = 100;
        knob_rim.height_request = 100;

        var event_box = new Gtk.EventBox ();
        event_box.event.connect (handle_event);
        event_box.hexpand = true;
        event_box.vexpand = true;

        add_overlay (knob_background);
        add_overlay (knob_cover);
        add_overlay (fixed);
        add_overlay (knob_rim);
        add_overlay (event_box);

        this.hexpand = false;
        this.vexpand = true;
        this.width_request = 128;
        this.height_request = 128;
    }

    public void rotate_dial (double value) {
        double px = RADIUS * GLib.Math.cos (value / Math.PI);
        double py = RADIUS * GLib.Math.sin (value / Math.PI);
        fixed.move (knob_socket_graphic, (int)(px + center), (int)(py + center));
        change_value ((value - 27.0) / 15.0);
    }

    public void set_value (double _value) {
        value = 15 * _value + 27;
        double px = RADIUS * GLib.Math.cos (value / Math.PI);
        double py = RADIUS * GLib.Math.sin (value / Math.PI);
        if (value == 35.2) {
            knob_rim.get_style_context ().add_class ("knob-rim-hidden");
        }
        fixed.move (knob_socket_graphic, (int)(px + center), (int)(py + center));
    }

    public bool handle_event (Gdk.Event event) {
        //  if (event.type == Gdk.EventType.ENTER_NOTIFY) {
        //      this.get_toplevel.set_cursor (Gdk.CursorType.HAND1));
        //  }
        //  if (event.type == Gdk.EventType.LEAVE_NOTIFY) {
        //      fixed.set_cursor (Gdk.CursorType.ARROW);
        //  }
        if (event.type == Gdk.EventType.BUTTON_PRESS) {
            dragging = true;
            drag_force = 0;
        }
        if (event.type == Gdk.EventType.BUTTON_RELEASE) {
            dragging = false;
            dragging_direction_x = 0;
            dragging_direction_y = 0;
        }

        if (event.type == Gdk.EventType.MOTION_NOTIFY && dragging) {
            if (dragging_direction_x == 0) {
                dragging_direction_x = event.motion.x;
            }
            if (dragging_direction_y == 0) {
                dragging_direction_y = event.motion.y;
            }
            double delta = 0.0;
            if (dragging_direction_x > event.motion.x || event.motion.x_root == 0) {
                delta -= 0.1 * (dragging_direction_x - event.motion.x);
                if (locked) {
                    drag_force += 1;
                }
                dragging_direction_x = event.motion.x;
            } else {
                delta += 0.1 * (event.motion.x - dragging_direction_x);
                if (locked) {
                    drag_force -= 1;
                }
                dragging_direction_x = event.motion.x;
            }
            if (dragging_direction_y > event.motion.y || event.motion.y_root == 0) {
                delta += 0.1 * (dragging_direction_y - event.motion.y);
                if (locked) {
                    drag_force += 1;
                }
                dragging_direction_y = event.motion.y;
            } else {
                delta -= 0.1 * (event.motion.y - dragging_direction_y);
                if (locked) {
                    drag_force -= 1;
                }
                dragging_direction_y = event.motion.y;
            }
            value += delta;
            if (value < 27) {
                value = 27;
            }
            if (value > 42) {
                value = 42;
            }
            if (value > 33.5 && value < 36.5 && !locked) {
                value = 35.2;
                locked = true;
                knob_rim.get_style_context ().add_class ("knob-rim-hidden");
            } else {
                knob_rim.get_style_context ().remove_class ("knob-rim-hidden");
            }
            if (drag_force < -1 || drag_force > 1) {
                locked = false;
            }
            rotate_dial (value);
        }
        return false;
    }
}
