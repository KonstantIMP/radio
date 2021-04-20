// Plot module define
module Plot;

// Import GRKd libraries
import gtk.ScrolledWindow, gtk.DrawingArea, gtk.Label, gtk.Overlay, gtk.Widget;

// Import Cairo for plot drawing
import cairo.Context;

// Framerate const
immutable uint FRAMERATE = 11025;

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
