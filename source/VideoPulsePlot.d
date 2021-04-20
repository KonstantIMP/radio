// VideoPulsePlot module define
module VideoPulsePlot;

// Import GTKd libs
import gtk.Widget;

// Import parent class
import Plot;

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