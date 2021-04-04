// Main module define
module Radio;

// GTKd import
import gtk.Application, gtk.Builder, gtk.Main;

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
            bc.addFromResource("/kimp/ui/radio.glade");
        }
        catch (Exception) {
            // TODO : make error message
        }

        
    });

    // Run the app
    return radio_app.run(args);
}
