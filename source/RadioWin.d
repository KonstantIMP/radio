//RadioWin moduel define
module RadioWin;

// Import GTKd libaries
import gtk.Window, gtk.Builder, gtk.Box; 

import VideoPulsePlot;

//
class RadioWin : Window {

    public this (ref Builder ui_builder, string window_id = "radio_win") {
        // Init parent instance
        super((cast(Window)ui_builder.getObject(window_id)).getWindowStruct());

        // Set window margins
        this.setBorderWidth(10);

        test_plot = new VideoPulsePlot();
    
        (cast(Box)ui_builder.getObject("plot_box")).packStart(test_plot, true, true, 0);
        test_plot.drawRequest();
    }

    private VideoPulsePlot test_plot;
}