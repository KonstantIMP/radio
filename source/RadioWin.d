//RadioWin moduel define
module RadioWin;

// Import GTKd libaries
import gtk.Window, gtk.Builder, gtk.Box; 

import Plot;

//
class RadioWin : Window {

    public this (ref Builder ui_builder, string window_id = "radio_win") {
        // Init parent instance
        super((cast(Window)ui_builder.getObject(window_id)).getWindowStruct());

        // Set window margins
        this.setBorderWidth(10);

        test_plot = new Plot("Hello");
    
        (cast(Box)ui_builder.getObject("plot_box")).packStart(test_plot, false, true, 0);
        test_plot.drawRequest();
    }

    private Plot test_plot;
}