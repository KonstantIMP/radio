module RadioWin;

import gtk.Window, gtk.Builder; 

class RadioWin : Window {

    public this (ref Builder ui_builder, string window_id = "radio_win") {
        super((cast(Window)ui_builder.getObject(window_id)).getWindowStruct());

        this.setBorderWidth(10);
    }
}