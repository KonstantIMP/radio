// Plot module define
module Plot;

// Import GRKd libraries
import gtk.ScrolledWindow, gtk.DrawingArea, gtk.Label, gtk.Overlay, gtk.Widget;

// Import Cairo for plot drawing
import cairo.Context;

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

    // @brief Create an points array to display
    // @return byte [] Points array to display
    private byte [] evaluate () {
        // Empty for basic (parent) class
        byte [] ys = new byte[0];
        return ys;
    }

    // @brief Calculate plot area size
    // For custom plots must be override
    // @return GtkAllocation with new widget size
    private GtkAllocation allocateSize () {
        GtkAllocation allocated_size;
        allocated_size.height = allocated_size.width = -1;
        allocated_size.x = allocated_size.y = 0;
        return allocated_size;
    }

    // @brief Sent draw request to GTK
    // Reallocate widget size and draw it again
    public final void drawRequest () {
        // Size reset
        plot_draw.setSizeRequest(0, 0);

        // Size reallocate
        GtkAllocation new_alloc = this.allocateSize();
        plot_draw.sizeAllocate(&new_alloc);

        // Draw request
        plot_draw.queueDraw();
    }

    private final bool onPlotAreaDraw (Scoped!Context cairo_context, Widget draw_area) {
        // Draw background (White)
        cairo_context.setSourceRgba(1.0, 1.0, 1.0, 1.0);
        cairo_context.paint();

        // Get drawing area size
        GtkAllocation w_alloc; draw_area.getAllocation(w_alloc);

        return true;
    }

    private Label plot_name_msg;
    private DrawingArea plot_draw;
    private ScrolledWindow plot_sw;
}
