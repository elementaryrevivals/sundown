/*
 * Copyright 2018-2019 Panos P. (https://github.com/panosx2/brightness) <panosp.dev@gmail.com>
 * Copyright 2021 Allie Law <allie@cloverleaf.app>
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

using Gtk;
using Gee;

public class Sundown : Gtk.Application {
    public static Gtk.Scale slider;
    public static Gtk.Scale slider1;
    public static Gtk.Scale slider2;
    public static Gtk.Scale slider3;
    public static Gtk.Scale slider4;

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
        Window window = new Gtk.ApplicationWindow (this);
        window.title = "Sundown";
        window.window_position = WindowPosition.CENTER;
        window.set_decorated (true);
        window.set_deletable (true);
        window.set_resizable (false);
        window.destroy.connect (Gtk.main_quit);
        window.border_width = 20;

        var vbox_main = new Box (Orientation.VERTICAL, 0);
        vbox_main.homogeneous = false;

        var vbox_ind = new Box (Orientation.VERTICAL, 0);
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

        //this is my main slider
        slider = new Scale.with_range (Orientation.HORIZONTAL, 40, 150, 1);
        slider.set_size_request (380, 50);

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
                    slider.visible = true;
                    vbox_ind.visible = false;

                    //initialization
                    set_value_for_all ();
                }
                else {
                    slider.visible = false;
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
            //slider1
            label1 = new Label (monitors[0]);
            label1.halign = Align.START;

            slider1 = new Scale.with_range (Orientation.HORIZONTAL, 40, 150, 1);
            slider1.set_size_request (380, 30);
            slider1.adjustment.value_changed.connect (() => {
                try {
                        string edited = (slider1.adjustment.value / 100).to_string ();

                        //if ((slider1.adjustment.value / 100) >= 1.0) {
                            //GLib.Process.spawn_command_line_async("xrandr --output " + monitors[0] + " --gamma " + edited + ":" + edited + ":" + edited);
                        //}
                        //else
                        GLib.Process.spawn_command_line_async ("xrandr --output " + monitors[0] + " --brightness " + edited);

                        save_value (".dimmer_" + monitors[0] + ".txt", edited);

                        if ((slider1.adjustment.value / 100) > 1.2) slider1.tooltip_text = "Too Bright";
                        else if ((slider1.adjustment.value / 100) < 0.6) slider1.tooltip_text = "Too Dark";
                        else slider1.tooltip_text = "";
                } catch (SpawnError se) {}
            });
            slider1.set_margin_bottom (30);

            //slider2
            label2 = new Label (monitors[1]);
            label2.halign = Align.START;

            slider2 = new Scale.with_range (Orientation.HORIZONTAL, 40, 150, 1);
            slider2.set_size_request (380, 30);
            slider2.adjustment.value_changed.connect (() => {
                try {
                    string edited = (slider2.adjustment.value / 100).to_string ();

                    GLib.Process.spawn_command_line_async ("xrandr --output " + monitors[1] + " --brightness " + edited);

                    save_value (".dimmer_" + monitors[1] + ".txt", edited);

                    if ((slider2.adjustment.value / 100) > 1.2) slider2.tooltip_text = "Too Bright";
                    else if ((slider2.adjustment.value / 100) < 0.6) slider2.tooltip_text = "Too Dark";
                    else slider2.tooltip_text = "";
                } catch (SpawnError se) {}
            });
            slider2.set_margin_bottom (30);

            //slider3
            label3 = new Label (monitors[2]);
            label3.halign = Align.START;

            slider3 = new Scale.with_range (Orientation.HORIZONTAL, 40, 150, 1);
            slider3.set_size_request (380, 30);
            slider3.adjustment.value_changed.connect (() => {
                try {
                        string edited = (slider3.adjustment.value / 100).to_string ();

                        GLib.Process.spawn_command_line_async ("xrandr --output " + monitors[2] + " --brightness " + edited);

                        save_value (".dimmer_" + monitors[2] + ".txt", edited);

                        if ((slider3.adjustment.value / 100) > 1.2) slider3.tooltip_text = "Too Bright";
                        else if ((slider3.adjustment.value / 100) < 0.6) slider3.tooltip_text = "Too Dark";
                        else slider3.tooltip_text = "";
                } catch (SpawnError se) {}
            });
            slider3.set_margin_bottom (30);

            //slider4
            label4 = new Label (monitors[3]);
            label4.halign = Align.START;

            slider4 = new Scale.with_range (Orientation.HORIZONTAL, 40, 150, 1);
            slider4.set_size_request (380, 30);
            slider4.adjustment.value_changed.connect (() => {
                try {
                        string edited = (slider4.adjustment.value / 100).to_string ();

                        GLib.Process.spawn_command_line_async ("xrandr --output " + monitors[3] + " --brightness " + edited);

                        save_value (".dimmer_" + monitors[3] + ".txt", edited);

                        if ((slider4.adjustment.value / 100) > 1.2) slider4.tooltip_text = "Too Bright";
                        else if ((slider4.adjustment.value / 100) < 0.6) slider4.tooltip_text = "Too Dark";
                        else slider4.tooltip_text = "";
                } catch (SpawnError se) {}
            });

            //set the values at start (when more than 1 exists)
            set_values_for_every_monitor ();

            if (slider1.get_value () != slider2.get_value ()) {
                switcher.set_active (false);
            }
        }

        //action for main slider
        slider.adjustment.value_changed.connect (() => {
            try {
                    string edited = (slider.adjustment.value / 100).to_string ();

                    for (int i = 0; i < lines.size; i++) GLib.Process.spawn_command_line_async ("xrandr --output " + lines.get (i) + " --brightness " + edited);

                    save_value (".dimmer_all_monitors.txt", edited);

                    if ((slider.adjustment.value / 100) > 1.2) slider.tooltip_text = "Too Bright";
                    else if ((slider.adjustment.value / 100) < 0.6) slider.tooltip_text = "Too Dark";
                    else slider.tooltip_text = "";
            } catch (SpawnError se) {}
        });

        //.v.positioning
        vbox_main.add (slider);

        if (lines.size > 1) {
            for (int i = 0; i < lines.size; i++) {
                if (i == 0) {
                    vbox_ind.add (label1);
                    vbox_ind.add (slider1);
                }
                else if (i == 1) {
                    vbox_ind.add (label2);
                    vbox_ind.add (slider2);
                }
                else if (i == 2) {
                    vbox_ind.add (label3);
                    vbox_ind.add (slider3);
                }
                else if (i == 3) {
                    vbox_ind.add (label4);
                    vbox_ind.add (slider4);
                }
            }
        }

        vbox_main.pack_end (vbox_ind, false, false, 0);

        window.add (vbox_main);

        window.show_all ();
    }

    //also, if only 1 monitor exists
    private static void set_value_for_all () {
        string prev_value;

        if (FileUtils.test (".dimmer_all_monitors.txt", GLib.FileTest.EXISTS) == true) {
            try {
                FileUtils.get_contents (".dimmer_all_monitors.txt", out prev_value);
            }
            catch (Error e) {
                prev_value = "1.00";
                stderr.printf ("Error: %s\n", e.message);
            }
        }
        else {
            prev_value = "1.00"; //default
        }

        double dprev_value = double.parse (prev_value);
        if (dprev_value < 0.4) dprev_value = 0.4;
        if (dprev_value > 1.5) dprev_value = 1.5;

        slider.adjustment.value = dprev_value * 100;

        string edited = dprev_value.to_string ();

        try {
            for (int i = 0; i < lines.size; i++) GLib.Process.spawn_command_line_async ("xrandr --output " + lines.get (i) + " --brightness " + edited);
        } catch (SpawnError se) {}
    }

    //if more than 1 monitor exists
    private static void set_values_for_every_monitor () {
        for (int i = 0; i < lines.size; i++) {
            string prev_value;

            if (monitors[i] != "") {
                if (FileUtils.test (".dimmer_" + monitors[i] + ".txt", GLib.FileTest.EXISTS) == true) {
                    try {
                        FileUtils.get_contents (".dimmer_" + monitors[i] + ".txt", out prev_value);
                    }
                    catch (Error e) {
                        prev_value = "1.00";
                        stderr.printf ("Error: %s\n", e.message);
                    }
                }
                else {
                    prev_value = "1.00"; //default
                }

                double dprev_value = double.parse (prev_value);
                if (dprev_value < 0.4) dprev_value = 0.4;
                if (dprev_value > 1.5) dprev_value = 1.5;

                if (i == 0) slider1.adjustment.value = dprev_value * 100;
                else if (i == 1) slider2.adjustment.value = dprev_value * 100;
                else if (i == 2) slider3.adjustment.value = dprev_value * 100;
                else if (i == 3) slider4.adjustment.value = dprev_value * 100;

                string edited = dprev_value.to_string ();

                try {
                    GLib.Process.spawn_command_line_async ("xrandr --output " + monitors[i] + " --brightness " + edited);
                } catch (SpawnError se) {}
            }
        }
    }

    private static void save_value (string filename, string value_to_save) {
        try {
            FileUtils.set_contents (filename, value_to_save);
        }
        catch (Error e) {
            stderr.printf ("Error: %s\n", e.message);
        }
    }

    public static int main (string[] args) {
        return new Sundown ().run (args);
    }
}
