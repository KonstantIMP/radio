//RadioWin moduel define
module radio.win;

// Import GTKd libaries
import gtk.Window, gtk.Builder, gtk.Box, gtk.Label, gtk.EditableIF, gtk.SpinButton, gtk.ComboBoxText, gtk.Button; 

// Import GLib and conv
import glib.Timeout, std.conv;

// Import plot widgets
import radio.plot;

// Modulation types
import radio.modulation;

// Main window class
class RadioWin : Window {
    // @brief Basic constructor
    // Init widgets and connect signals
    public this (ref Builder ui_builder, string window_id = "radio_win") {
        // Init parent instance
        super((cast(Window)ui_builder.getObject(window_id)).getWindowStruct());

        // Set window margins
        this.setBorderWidth(10);

        // Create plots instances
        video_plot = new VideoPulsePlot();
        radio_plot = new RadioPulsePlot();
        noise_plot = new NoiseRadioPulsePlot();
        output_plot = new OutputDataPlot();
    
        error_percent_msg = (cast(Label)ui_builder.getObject("error_percent_msg"));

        // Add plots to UI form
        (cast(Box)ui_builder.getObject("plot_box")).packStart(video_plot, true, true, 0);
        (cast(Box)ui_builder.getObject("plot_box")).packStart(radio_plot, true, true, 0);
        (cast(Box)ui_builder.getObject("plot_box")).packStart(noise_plot, true, true, 0);
        (cast(Box)ui_builder.getObject("plot_box")).packStart(output_plot, true, true, 0);

        // Connect signals
        (cast(EditableIF)ui_builder.getObject("bits_en")).addOnChanged(&onBitsChanged);

        (cast(SpinButton)ui_builder.getObject("freq_sb")).addOnValueChanged(&onFreqChanged);
        (cast(SpinButton)ui_builder.getObject("informativeness_sb")).addOnValueChanged(&onInformativenessChanges);
    
        (cast(ComboBoxText)ui_builder.getObject("modulation_cb")).addOnChanged(&onModulationTypeChanged);
    
        (cast(SpinButton)ui_builder.getObject("noise_sb")).addOnValueChanged(&onNoiseChanged);

        (cast(Button)ui_builder.getObject("regen_btn")).addOnClicked(delegate void(_) {noise_plot.drawRequest();});

        // Connect timers
        ui_updater = new Timeout(500, &updateUI);
    }

    // @brief onBitsChanged Don't allow input non-1 and non-0 to bit sequence entry
    private void onBitsChanged (EditableIF en) {
        // Get entered symbol
        string input_sym = en.getChars(en.getPosition(), en.getPosition() + 1);
        
        // Check it (must be 0 or 1)
        if (input_sym.length) {
            if(input_sym[0] != '0' && input_sym[0] != '1') {
                // Delete incorrect symbols
                string correct_out = en.getChars(0, en.getPosition()) ~ en.getChars(en.getPosition() + 1, -1);

                en.deleteText(0, -1); int zero = 0;
                en.insertText(correct_out, cast(int)correct_out.length, zero);
            }
        }

        // Set new bits
        video_plot.setBitSequence(en.getChars(0, -1));
        radio_plot.setBitSequence(en.getChars(0, -1));
        noise_plot.setBitSequence(en.getChars(0, -1));
        output_plot.setBitSequence(en.getChars(0, -1));

        // Sent draw request
        plotsUpdate();
    }

    // @brief onFreqChanged Change frequency at plots
    private void onFreqChanged (SpinButton freq_sb) {
        // Set new freq
        radio_plot.setFrequency(freq_sb.getValue());
        noise_plot.setFrequency(freq_sb.getValue());
        output_plot.setFrequency(freq_sb.getValue());

        // Sent draw request
        plotsUpdate();
    }

    // @brief onInformativenessChanges Change informativeness value at plot's
    private void onInformativenessChanges (SpinButton informativeness_sb) {
        // Set new informativeness
        video_plot.setInformativeness(informativeness_sb.getValue());
        radio_plot.setInformativeness(informativeness_sb.getValue());
        noise_plot.setInformativeness(informativeness_sb.getValue());
        output_plot.setInformativeness(informativeness_sb.getValue());

        // Sent draw request
        plotsUpdate();
    }

    // @brief onModulationTypeChanged Change Modulation type at plot's
    private void onModulationTypeChanged (ComboBoxText modulation_cb) {
        // Set new modulation type
        radio_plot.setModulationType(cast(ModulationType)(modulation_cb.getActive()));
        noise_plot.setModulationType(cast(ModulationType)(modulation_cb.getActive()));
        output_plot.setModulationType(cast(ModulationType)(modulation_cb.getActive()));

        // Sent draw request
        plotsUpdate();
    }

    // @brief onNoiseChanged Change noise power
    private void onNoiseChanged (SpinButton noise_sb) {
        // Set new noise power
        noise_plot.setNoise(noise_sb.getValue());
        output_plot.setNoise(noise_sb.getValue());

        // Sent draw request
        plotsUpdate();
    }

    // @brief Sent draw requests to plot widgets
    private void plotsUpdate() {
        video_plot.drawRequest();
        radio_plot.drawRequest();
        noise_plot.drawRequest();
        output_plot.drawRequest();
    }

    // @brief Function for ui updating
    protected bool updateUI() {
        string output = output_plot.getOutputBits();
        string input = radio_plot.getBitSequence();
        float result = 0.0; 

        if (output.length) {
            for (ulong i = 0; i < output.length; i++) {
                if (input[i] == output[i]) result += 1.0;
            }

            error_percent_msg.setText(to!string((1 - result / output.length) * 100.0) ~ " %");
        }

        return true;
    }

    // VideoPulsePlot object
    private VideoPulsePlot video_plot;
    // RadioPulsePlot object
    private RadioPulsePlot radio_plot;
    // NoiseRadioPulsePlot object
    private NoiseRadioPulsePlot noise_plot;
    // OutputDataPlot object
    private OutputDataPlot output_plot;
    // Label with errors percent
    private Label error_percent_msg;
    // UI updating timeout
    private Timeout ui_updater;
}
