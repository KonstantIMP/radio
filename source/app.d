// Main module define
module Radio;

// GTKd import
import gtk.Application, gtk.Builder, gtk.Main, gtk.MessageDialog;

// Main window class
import radio.win;

// radio start point
int main(string [] args) {
    // GTKd init
    Main.init(args);
    
    // Create and register the app
    Application radio_app = new Application("org.radio.kimp", GApplicationFlags.FLAGS_NONE);

    // App init
    radio_app.addOnActivate( (gio.Application.Application) {
        // Load UI file
        Builder bc = new Builder();

        try {
            version(linux) bc.addFromResource("/kimp/ui/radio.glade");
            else bc.addFromFile("..\\res\\radio.glade");
        }
        catch (Exception) {
            MessageDialog err = new MessageDialog(null, GtkDialogFlags.MODAL | GtkDialogFlags.USE_HEADER_BAR,
                    GtkMessageType.ERROR, GtkButtonsType.OK, true, "<span size='x-large'>Внимание!</span>\nПроизошла <span underline='single' font_weight='bold'>критическая ошибка</span> с загрузкой ресурсов.\nПереустановите программу для решения проблемы!  <span size='small'>(╯°^°)╯┻━┻</span>", null);
            radio_app.addWindow(err); err.showAll(); err.run();
            err.destroy();

            radio_app.quit(); return;
        }

        // Create and show main window
        RadioWin radio_win = new RadioWin(bc);
        radio_win.showAll(); radio_app.addWindow(radio_win);
    });

    // Run the app
    return radio_app.run(args);
}
