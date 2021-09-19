/*
 * Copyright 2018-2019 Panos P. (https://github.com/panosx2/brightness) <panosp.dev@gmail.com>
 * Copyright 2021 Allie Law <allie@cloverleaf.app>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

using Gtk;
using Gee;
GLib.Settings settings;

public class Sundown : Gtk.Application {
    Gtk.CssProvider css_provider;
    //  public static Gtk.Scale slider;
    //  public static Gtk.Scale slider1;
    //  public static Gtk.Scale slider2;
    //  public static Gtk.Scale slider3;
    //  public static Gtk.Scale slider4;

    public static Knob knob;
    public static Knob knob1;
    public static Knob knob2;
    public static Knob knob3;
    public static Knob knob4;

    public static Label label1;
    public static Label label2;
    public static Label label3;
    public static Label label4;

    public static Switch switcher;

    public static ArrayList<string> lines;
    public static string[] monitors;

     public Sundown () {
        Object (
            application_id: "com.github.watsonprojects.sundown",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    protected override void activate () {
        settings = new GLib.Settings ("com.github.elementaryrevivals.sundown");
        init_theme ();
        Gtk.Settings gsettings = Gtk.Settings.get_default ();
        gsettings.gtk_application_prefer_dark_theme = false;
        var header_bar = new Gtk.HeaderBar ();
        header_bar.set_show_close_button (true);
        header_bar.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        header_bar.get_style_context ().add_class ("default-decoration");
        header_bar.set_title ("Sundown");
        if (css_provider == null) {
            css_provider = new Gtk.CssProvider ();
            css_provider.load_from_resource ("/com/github/elementaryrevivals/sundown/Application.css");
            // CSS Provider
            Gtk.StyleContext.add_provider_for_screen (
                Gdk.Screen.get_default (),
                css_provider,
                Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
            );
        }
        Window window = new Gtk.ApplicationWindow (this);
        window.set_titlebar (header_bar);
        window.window_position = WindowPosition.CENTER;
        window.set_decorated (true);
        window.set_deletable (true);
        window.set_resizable (false);
        window.destroy.connect (Gtk.main_quit);
        window.border_width = 20;
        window.width_request = 268;
        window.get_style_context ().add_class ("rounded");

        var vbox_main = new Box (Orientation.VERTICAL, 0);
        vbox_main.homogeneous = false;

        var vbox_ind = new Box (Orientation.HORIZONTAL, 0);
        vbox_ind.homogeneous = false;

        string current_brightness, /*currentGm,*/ names;

        try {
                GLib.Process.spawn_command_line_sync ("sh -c \"xrandr --verbose | grep -m 1 -i brightness | cut -f2 -d ' '\"", out current_brightness);
        } catch (SpawnError se) { current_brightness = "100"; }

        /*
        try {
                GLib.Process.spawn_command_line_sync("sh -c \"xrandr --verbose | grep -m 1 -i gamma | cut -f2 -d ' '\"", out currentGm);
        } catch (SpawnError se) { currentGm = "1.0:1.0:1.0"; }
        */

        try {
                GLib.Process.spawn_command_line_sync ("sh -c \"xrandr | grep ' connected ' | awk '{ print$1 }'\"", out names);
        } catch (SpawnError se) { names = ""; }

        string[] temp_lines = names.split ("\n");

        lines = new ArrayList<string> ();

        for (int i = 0; i < temp_lines.length; i++) if (temp_lines[i] != "") lines.add (temp_lines[i]);

        //this is my main knob
        //  slider = new Scale.with_range (Orientation.HORIZONTAL, 40, 150, 1);
        //  slider.set_size_request (380, 50);
        knob = new Knob ();

        if (lines.size > 1) {
            var hbox_all = new Box (Orientation.HORIZONTAL, 0);
            hbox_all.homogeneous = false;

            var label = new Label ("All Monitors:");
            label.halign = Align.START;
            label.set_margin_bottom (30);

            switcher = new Switch ();
            switcher.active = true;
            switcher.state_flags_changed.connect (() => {
                if (switcher.active == true) {
                    //  slider.visible = true;
                    knob.visible = true;
                    vbox_ind.visible = false;

                    //initialization
                    set_value_for_all ();
                }
                else {
                    //  slider.visible = false;
                    knob.visible = false;
                    vbox_ind.visible = true;

                    //initialization
                    set_values_for_every_monitor ();
                }
            });
            switcher.set_margin_bottom (30);

            hbox_all.pack_start (label, false, false, 0);
            hbox_all.pack_end (switcher, false, false, 0);

            vbox_main.add (hbox_all);
        }
        else { //if only one exists
            //initialization
            set_value_for_all ();
        }

        monitors = {"", "", "", ""};

        for (int i = 0; i < lines.size; i++) monitors[i] = lines.get (i);

        if (lines.size > 1) {
            //knob1
            label1 = new Label (monitors[0]);
            label1.halign = Align.START;

            knob1 = new Knob ();
            knob1.change_value.connect ((value) => {
                double val = (int)(40 + (110.0 * value)) / 100.0;
                //print ("%lf\n", val);
                Idle.add (() => {
                    try {
                        GLib.Process.spawn_command_line_async ("xrandr --output " + monitors[0] + " --brightness " + val.to_string ());
                        settings.set_double ("monitors-1-brightness", value);
                        if (val > 1.2) knob.tooltip_text = "Too Bright";
                        else if (val < 0.6) knob.tooltip_text = "Too Dark";
                        else knob.tooltip_text = "";
                    } catch (SpawnError se) {}
                    return false;
                });
            });
            //knob2
            label2 = new Label (monitors[1]);
            label2.halign = Align.START;

            knob2 = new Knob ();
            knob2.change_value.connect ((value) => {
                double val = (int)(40 + (110.0 * value)) / 100.0;
                //print ("%lf\n", val);
                Idle.add (() => {
                    try {
                        GLib.Process.spawn_command_line_async ("xrandr --output " + monitors[1] + " --brightness " + val.to_string ());
                        settings.set_double ("monitors-2-brightness", value);
                        if (val > 1.2) knob.tooltip_text = "Too Bright";
                        else if (val < 0.6) knob.tooltip_text = "Too Dark";
                        else knob.tooltip_text = "";
                    } catch (SpawnError se) {}
                    return false;
                });
            });

            //knob3
            label3 = new Label (monitors[2]);
            label3.halign = Align.START;

            knob3 = new Knob ();
            knob3.change_value.connect ((value) => {
                double val = (int)(40 + (110.0 * value)) / 100.0;
                //print ("%lf\n", val);
                Idle.add (() => {
                    try {
                        GLib.Process.spawn_command_line_async ("xrandr --output " + monitors[2] + " --brightness " + val.to_string ());
                        settings.set_double ("monitors-3-brightness", value);
                        if (val > 1.2) knob.tooltip_text = "Too Bright";
                        else if (val < 0.6) knob.tooltip_text = "Too Dark";
                        else knob.tooltip_text = "";
                    } catch (SpawnError se) {}
                    return false;
                });
            });

            //knob4
            label4 = new Label (monitors[3]);
            label4.halign = Align.START;

            knob4 = new Knob ();
            knob4.change_value.connect ((value) => {
                double val = (int)(40 + (110.0 * value)) / 100.0;
                //print ("%lf\n", val);
                Idle.add (() => {
                    try {
                        GLib.Process.spawn_command_line_async ("xrandr --output " + monitors[3] + " --brightness " + val.to_string ());
                        settings.set_double ("monitors-4-brightness", value);
                        if (val > 1.2) knob.tooltip_text = "Too Bright";
                        else if (val < 0.6) knob.tooltip_text = "Too Dark";
                        else knob.tooltip_text = "";
                    } catch (SpawnError se) {}
                    return false;
                });
            });

            //set the values at start (when more than 1 exists)
            set_values_for_every_monitor ();

            if (knob1.value != knob2.value) {
                switcher.set_active (false);
            }
        }

        //action for main knob
        knob.change_value.connect ((value) => {
            double val = (int)(40 + (110.0 * value)) / 100.0;
            //print ("%lf\n", val);
            Idle.add (() => {
                try {
                    for (int i = 0; i < lines.size; i++) GLib.Process.spawn_command_line_async ("xrandr --output " + lines.get (i) + " --brightness " + val.to_string ());
                    settings.set_double ("all-monitors-brightness", value);
                    if (val > 1.2) knob.tooltip_text = "Too Bright";
                    else if (val < 0.6) knob.tooltip_text = "Too Dark";
                    else knob.tooltip_text = "";
                } catch (SpawnError se) {}
                return false;
            });
        });

        //.v.positioning
        vbox_main.add (knob);

        if (lines.size > 1) {
            for (int i = 0; i < lines.size; i++) {
                if (i == 0) {
                    vbox_ind.add (label1);
                    vbox_ind.add (knob1);
                }
                else if (i == 1) {
                    vbox_ind.add (label2);
                    vbox_ind.add (knob2);
                }
                else if (i == 2) {
                    vbox_ind.add (label3);
                    vbox_ind.add (knob3);
                }
                else if (i == 3) {
                    vbox_ind.add (label4);
                    vbox_ind.add (knob4);
                }
            }
        }

        vbox_main.pack_end (vbox_ind, false, false, 0);

        window.add (vbox_main);

        window.show_all ();
    }

    //also, if only 1 monitor exists
    private static void set_value_for_all () {
        double value = settings.get_double ("all-monitors-brightness");
        double prev_value = (int)(40 + (110.0 * value)) / 100.0;

        if (prev_value < 0.4) prev_value = 0.4;
        if (prev_value > 1.5) prev_value = 1.5;

        knob.set_value (value);

        string edited = prev_value.to_string ();

        try {
            for (int i = 0; i < lines.size; i++) GLib.Process.spawn_command_line_async ("xrandr --output " + lines.get (i) + " --brightness " + edited);
        } catch (SpawnError se) {}
    }

    //if more than 1 monitor exists
    private static void set_values_for_every_monitor () {
        for (int i = 0; i < lines.size; i++) {

            if (monitors[i] != "") {
                double value = settings.get_double ("all-monitors-brightness");
                double prev_value = (int)(40 + (110.0 * value)) / 100.0;

                if (prev_value < 0.4) prev_value = 0.4;
                if (prev_value > 1.5) prev_value = 1.5;

                if (i == 0) knob1.set_value (value);
                else if (i == 1) knob2.set_value (value);
                else if (i == 2) knob3.set_value (value);
                else if (i == 3) knob4.set_value (value);

                string edited = prev_value.to_string ();

                try {
                    GLib.Process.spawn_command_line_async ("xrandr --output " + monitors[i] + " --brightness " + edited);
                } catch (SpawnError se) {}
            }
        }
    }

    //  private static void save_value (string filename, string value_to_save) {
    //      try {
    //          FileUtils.set_contents (filename, value_to_save);
    //      }
    //      catch (Error e) {
    //          stderr.printf ("Error: %s\n", e.message);
    //      }
    //  }

    private void init_theme () {
        GLib.Value value = GLib.Value (GLib.Type.STRING);
        Gtk.Settings.get_default ().get_property ("gtk-theme-name", ref value);
        if (!value.get_string ().has_prefix ("io.elementary.")) {
            Gtk.Settings.get_default ().set_property ("gtk-icon-theme-name", "elementary");
            Gtk.Settings.get_default ().set_property ("gtk-theme-name", "io.elementary.stylesheet.blueberry");
        }
    }

    public static int main (string[] args) {
        return new Sundown ().run (args);
    }
}
