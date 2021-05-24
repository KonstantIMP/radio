// Plot module define
module radio.plot;

// Import ModulationTypes
import radio.modulation;

// Import conversation library
import std.conv;

// Import libraries for noise calculating
import std.math, std.random, radio.array;

// Import GRKd libraries
import gtk.ScrolledWindow, gtk.DrawingArea, gtk.Label, gtk.Overlay, gtk.Widget;

// Import Cairo for plot drawing
import cairo.Context;

// Framerate const
immutable uint FRAMERATE = 11025;

// PI * 2 const
immutable float PI2 = PI * 2;

// @brief Widget for plot drawing
// It is a composite widget with the struct :
// GtkOverlay (Parent)
// |___ GtkScrolledWindow (Child for Overlay)
// |    |___ GtkDrawingArea (Child for Scrolled Window)
// |___ GtkLabel (Overlay)
// This widget draw plot by cairo and show plot's name as overlay
// * Plot's name always visible
class Plot : Overlay {
    // @brief Plot constructor
    // Creates new Plot instance
    // @param[in] plot_name Plot's name
    public this (immutable string plot_name) {
        super(); // Parent's class init

        // Children and overlay init
        plot_draw = new DrawingArea();
        plot_name_msg = new Label("");
        plot_sw = new ScrolledWindow();

        // Create widget's struct
        this.add(cast(Widget)(plot_sw));
        plot_sw.add(cast(Widget)plot_draw);
        plot_sw.setSizeRequest(400, 100);
        this.addOverlay(cast(Widget)(plot_name_msg));

        // Set plot name
        plot_name_msg.setUseMarkup(true);
        plot_name_msg.setMarkup("<span size='small' foreground='#000000'>" ~ plot_name ~ "</span>");
    
        // Set plot name position
        plot_name_msg.setProperty("margin", 5);
        plot_name_msg.setProperty("halign", GtkAlign.END);
        plot_name_msg.setProperty("valign", GtkAlign.START);

        // Connect drawing slot
        plot_draw.addOnDraw(&this.onPlotAreaDraw);
    }

    // @brief Change plot's name
    public void setPlotName (immutable string plot_name) {
        // Set plot name
        plot_name_msg.setMarkup("<span size='small' foreground='#000000'>" ~ plot_name ~ "</span>");
    }

    // @brief Create an points array to display
    // @return byte [] Points array to display
    protected float [] createYS () {
        // Empty for basic (parent) class
        float [] ys = new float[0];
        return ys;
    }

    // @brief Calculate plot area size
    // For custom plots must be override
    // @return GtkAllocation with new widget size
    protected GtkAllocation allocateSize () {
        GtkAllocation allocated_size;
        allocated_size.height = allocated_size.width = -1;
        return allocated_size;
    }

    // @brief Sent draw request to GTK
    // Reallocate widget size and draw it again
    public final void drawRequest () {
        // Size reset
        plot_draw.setSizeRequest(0, 0);

        // Size reallocate
        GtkAllocation new_alloc = this.allocateSize();
        plot_draw.setSizeRequest(new_alloc.width, new_alloc.height);

        // Draw request
        plot_draw.queueDraw();
    }

    // @brief onPlotAreaDraw Plot drawer
    // This slot is called every time plot redraw
    // @param[in]  cairo_context Cairo context for actually draw
    // @param[in]  draw_area     Widget that contains cairo surface for drawing
    // @return     bool          True if drawing was succesfull (Every time)
    private final bool onPlotAreaDraw (Scoped!Context cairo_context, Widget draw_area) {
        // Draw background (White)
        cairo_context.setSourceRgba(1.0, 1.0, 1.0, 1.0);
        cairo_context.paint();

        // Get drawing area size
        GtkAllocation w_alloc; draw_area.getAllocation(w_alloc);

        // Create ys array
        float [] ys = this.createYS();

        // Prepare for axes drawing
        cairo_context.setSourceRgba(0.0, 0.0, 0.0, 1.0);
        cairo_context.setLineWidth(2);

        // Calculate zero Y point and amplitude (because ys must contain values from -1 to 1)
        float y_zero = w_alloc.height - 20; // Default value (for ys without < 0 values)
        float ampl = w_alloc.height / 6 * 3.75; // Default value
        for (ulong i = 0; i < ys.length; i = i + (FRAMERATE / 100)) {
            if (ys[i] < 0) {
                // The Y-center of plot
                y_zero = w_alloc.height / 2;
                // Increase ampl value
                ampl = ampl / 2;
                break;
            }
        }

        // Draw Y axix
        cairo_context.moveTo(20, w_alloc.height - 10);
        cairo_context.lineTo(20, 10);
        cairo_context.relLineTo(+2, +5);
        cairo_context.relLineTo(-4, 0);
        cairo_context.relLineTo(+2, -5);
        cairo_context.stroke();

        // Draw X axis
        cairo_context.moveTo(10, y_zero);
        cairo_context.relLineTo(w_alloc.width - 20, 0);
        cairo_context.relLineTo(-5, +2);
        cairo_context.relLineTo(0, -4);
        cairo_context.relLineTo(+5, +2);
        cairo_context.stroke();

        // Draw axes names
        cairo_context.setFontSize(10);
        cairo_context.moveTo(6, 15); cairo_context.showText("А");
        cairo_context.moveTo(w_alloc.width - 30, w_alloc.height - 5); cairo_context.showText("t(сек.)");

        // Draw Y axis markup
        cairo_context.moveTo(5, y_zero - ampl + 3); cairo_context.showText("1");
        cairo_context.moveTo(5, y_zero + ampl + 3); cairo_context.showText("-1");
        cairo_context.moveTo(16, y_zero + ampl); cairo_context.relLineTo(8, 0);
        cairo_context.moveTo(16, y_zero - ampl); cairo_context.relLineTo(8, 0);
        cairo_context.stroke();

        // Set plot line params
        cairo_context.setSourceRgba(0.0, 1.0, 0.0, 1.0);
        cairo_context.setLineWidth(1);

        // Actually plot line
        // Step calculate
        float step = cast(double)(w_alloc.width - 50) / ys.length;
        // Start point
        float current_point = 20;
        // Move cursor at (0; 0)
        cairo_context.moveTo(20, y_zero);

        // Draw it
        for (ulong i = 0; i < ys.length; i++) {
            cairo_context.lineTo(current_point, y_zero - (ys[i] * ampl));
            current_point = current_point + step;
        } cairo_context.stroke();

        // Clear the memory
        ys.destroy();

        return true;
    }

    // Lable with plot name
    private Label plot_name_msg;
    // Area with plot (cairo_surface)
    private DrawingArea plot_draw;
    // Scrollers for plot scaling
    private ScrolledWindow plot_sw;
}

// VideoPulsePlot class define
class VideoPulsePlot : Plot {
    // @brief VideoPulsePlot constructor
    // Init parent class abd set plot's name
    // Also init values like informativeness and bits
    public this () { super("График видеоимпульса");
        informativeness = 50.0; bits = "";
    }

    // @brief Calculate plot area size
    // Set height as parent's and width as bits.length
    override protected GtkAllocation allocateSize () {
        GtkAllocation allocated_size;
        allocated_size.width = cast(int)(60 + (bits.length * 30));
        allocated_size.height = -1;
        return allocated_size;
    }

    // @brief Create array of point coordinates
    // For high level - 1.0, for low - 0.0
    override protected float [] createYS () {
        // Create ys array with needed length
        float [] ys = new float[bits.length * cast(ulong)(FRAMERATE / informativeness)];

        // Zero check
        if (ys.length < bits.length * 30) {
            informativeness = informativeness / 2;
            drawRequest(); return ys;
        }

        // Setting values
        for (ulong i = 0; i < bits.length; i++) {
            for(ulong j = 0; j < cast(ulong)(FRAMERATE / informativeness); j++) {
                if (bits[i] == '0') ys[i * cast(ulong)(FRAMERATE / informativeness) + j] = 0.0;
                else ys[i * cast(ulong)(FRAMERATE / informativeness) + j] = 1.0;
            }
        }

        //Close plot line
        if (ys.length) ys[ys.length - 1] = 0;

        return ys;
    }

    // @brief setInformativeness Setter for informativeness
    public void setInformativeness (float informativeness_value) {
        informativeness = informativeness_value;
    }

    // @brief setBitSequence Setter for bits
    public void setBitSequence (string bit_sequence) {
        bits = bit_sequence;
    }

    // Informativeness for size calculating
    private float informativeness;
    // Bit sequence for displaing
    private string bits;
}

// RadioPulsePlot class define
class RadioPulsePlot : Plot {
    // @brief RadioPulsePlot constructor
    // Init parent class abd set plot's name
    // Also init values like informativeness, freq, modulation and bits
    public this () { super("График радиосигнала");
        informativeness = 50.0; freq = 100.0;
        bits = ""; modulation = ModulationType.FREQUENCY;
    }

    // @brief Calculate plot area size
    // Set height as parent's and width as bits.length
    override protected GtkAllocation allocateSize () {
        GtkAllocation allocated_size;
        allocated_size.width = cast(int)(60 + (bits.length * 30));
        allocated_size.height = -1;
        return allocated_size;
    }

    // @brief Create array of point coordinates
    // Create sinusoidal signal with freq and modulate it
    override protected float [] createYS () {
        // Create ys array with needed length
        float [] ys = new float[bits.length * cast(ulong)(FRAMERATE / informativeness)];

        // Zero check
        if (ys.length < bits.length * 60) {
            informativeness = informativeness / 2;
            freq = freq / 2;
            drawRequest(); return ys;
        }

        // Addititon variables for PHASE modulation
        int cur_phase = 1;
        if (bits.length) if (bits[0] == '0') cur_phase = -1;

        // Setting values
        for (ulong i = 0; i < bits.length; i++) {
            if(i) if (bits[i] != bits[i - 1]) cur_phase = -cur_phase;
            for(ulong j = 0; j < cast(ulong)(FRAMERATE / informativeness); j++) {
                switch (modulation) {
                    case ModulationType.PHASE :
                        ys[i * cast(ulong)(FRAMERATE / informativeness) + j] = sin(PI2 * freq * (i * cast(ulong)(FRAMERATE / informativeness) + j) / FRAMERATE) * cur_phase;
                        break;
                    default :
                        if (bits[i] == '1') ys[i * cast(ulong)(FRAMERATE / informativeness) + j] = sin(PI2 * freq * (i * cast(ulong)(FRAMERATE / informativeness) + j) / FRAMERATE);
                        else ys[i * cast(ulong)(FRAMERATE / informativeness) + j] = sin(PI * freq * (i * cast(ulong)(FRAMERATE / informativeness) + j) / FRAMERATE);
                        break;
                }
            }
        }

        //Close plot line
        if (ys.length) ys[ys.length - 1] = 0;

        return ys;
    }

    // @brief setInformativeness Setter for informativeness
    public void setInformativeness (float informativeness_value) {
        informativeness = informativeness_value;
    }

    // @brief setBitSequence Setter for bits
    public void setBitSequence (string bit_sequence) {
        bits = bit_sequence;
    }

    // @brief setFrequency Setter for freq
    public void setFrequency (float frequency_value) {
        freq = frequency_value;
    }

    // @brief setModulationType Setter for modulation
    public void setModulationType (ModulationType modulation_type_value) {
        modulation = modulation_type_value;
    }

    // Informativeness for size calculating
    protected float informativeness;
    // Bit sequence for displaing
    protected string bits;
    // Radio signal main frequency
    protected float freq;

    // Signal and radio frequency sum type
    protected ModulationType modulation;
}

// NoiseRadioPulsePlot class
class NoiseRadioPulsePlot : RadioPulsePlot {
    // @brief NoiseRadioPlot constructor
    // Init parent's class and set params
    public this () { super();
        // Set another plot name
        this.setPlotName("Полученный радиосигнал");
    
        // Set default noise value
        noise = 25;
    }

    // @brief Create array of point coordinates
    // Create sinusoidal signal with freq, modulate it and sum with noise
    override protected float [] createYS () {
        // Get basic signal YS array
        float [] ys = super.createYS();

        // Calculate noise amplitude
        float noise_amp = 2.0 / (pow(10.0, (noise / 20.0)));

        // Variables for Box-Muller transform
        float r = 0.0, q = 0.0;

        // Sum noise and signal
        for (ulong i = 0; i < ys.length; i++) {
            r = uniform!"(]"(0.0f, 1.0f); q = uniform!"(]"(0.0f, 1.0f);
            ys[i] = ys[i] + noise_amp * (cos(PI2 * q) * sqrt((-2) * log(r)));
        }

        return ys;
    }

    // @brief setNoise Setter for noise
    public void setNoise (float noise_value) {
        noise = noise_value;
    }

    // Signal's noise power
    protected float noise;
}

// OutputDataPlot class define
class OutputDataPlot : NoiseRadioPulsePlot {
    // Default constructor
    public this () { super();
        // Set another plot name
        this.setPlotName("Выделение полезной нагрузки");
        // Zero values
        output_bits = "";
    }

    // @brief Create array of point coordinates
    // Calculate usefull signal frame from signal with noise
    override protected float [] createYS () {
        // YS array
        float [] ys = super.createYS();

        // Get useless signal
        for (ulong i = 0; i < ys.length; i++) {
            ys[i] = (ys[i] - (sin(PI2 * freq * (i) / FRAMERATE))) * 0.5;
            if (ys[i] < 0) ys[i] = 0 - ys[i];
        } output_bits = "";

        float medium_val = (min(ys) + max(ys)) / 2;
        ulong new_bits_l = ys.length / cast(ulong)(FRAMERATE / informativeness);

        for (ulong i = 0; i < new_bits_l; i++) {
            if (medium_val < max(ys[i * (ys.length / new_bits_l) .. (i + 1) * (ys.length / new_bits_l)])) output_bits ~= '0';
            else output_bits ~= '1';
        }

        debug {
            import std.stdio;
            writeln(output_bits);
        }

        return ys;
    }

    // Calculated signal
    private string output_bits;
    // @brief getOutputBits getter for output bits
    public string getOutputBits () { return output_bits; }
}
