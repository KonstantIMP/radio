//RadioWin moduel define
module RadioWin;

// Import GTKd libaries
import gtk.Window, gtk.Builder, gtk.Box; 

import VideoPulsePlot;
import RadioPulsePlot;

//
class RadioWin : Window {

    public this (ref Builder ui_builder, string window_id = "radio_win") {
        // Init parent instance
        super((cast(Window)ui_builder.getObject(window_id)).getWindowStruct());

        // Set window margins
        this.setBorderWidth(10);

        video_plot = new VideoPulsePlot();
        radio_plot = new RadioPulsePlot();
    
        (cast(Box)ui_builder.getObject("plot_box")).packStart(video_plot, true, true, 0);
        (cast(Box)ui_builder.getObject("plot_box")).packStart(radio_plot, true, true, 0);
    }

    private VideoPulsePlot video_plot;
    private RadioPulsePlot radio_plot;
}