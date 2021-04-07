// RadioPulsePlot module define
module RadioPulsePlot;

// Import supported Modulation Types enum
import ModulationType;

// Import parent class
import Plot;

// Import GTKd libraries
import gtk.Widget;

// Import math module
import std.math;

immutable float PI2 = PI * 2;

// RadioPulsePlot class define
class RadioPulsePlot : Plot {
    // @brief RadioPulsePlot constructor
    // Init parent class abd set plot's name
    // Also init values like informativeness, freq, modulation and bits
    public this () { super("График радиосигнала");
        informativeness = 50.0; freq = 100.0;
        bits = "010011"; modulation = ModulationType.ModulationType.FREQUENCY;
    }

    // @brief Calculate plot area size
    // Set height as parent's and width as bits.length
    override protected GtkAllocation allocateSize () {
        GtkAllocation allocated_size;
        allocated_size.width = cast(int)(60 + (bits.length * 15));
        allocated_size.height = -1;
        return allocated_size;
    }

    // @brief Create array of point coordinates
    // Create sinusoidal signal with freq and modulate it
    override protected float [] createYS () {
        // Create ys array with needed length
        float [] ys = new float[bits.length * cast(ulong)(FRAMERATE / informativeness)];

        // Addititon variables for PHASE modulation
        int cur_phase = 1;
        if (bits.length) if (bits[0] == '0') cur_phase = -1;

        // Setting values
        for (ulong i = 0; i < bits.length; i++) {
            if(i) if (bits[i] != bits[i - 1]) cur_phase = -cur_phase;
            for(ulong j = 0; j < cast(ulong)(FRAMERATE / informativeness); j++) {
                switch (modulation) {
                    case ModulationType.ModulationType.AMPLITUDE :
                        if (bits[i] == '1') ys[i * cast(ulong)(FRAMERATE / informativeness) + j] = sin(PI2 * freq * (i * cast(ulong)(FRAMERATE / informativeness) + j) / FRAMERATE);
                        else ys[i * cast(ulong)(FRAMERATE / informativeness) + j] = sin(PI2 * freq * (i * cast(ulong)(FRAMERATE / informativeness) + j) / FRAMERATE) * 0.5;
                        break;
                    case ModulationType.ModulationType.PHASE :
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

    // Informativeness for size calculating
    private float informativeness;
    // Bit sequence for displaing
    private string bits;
    // Radio signal main frequency
    private float freq;

    // Signal and radio frequency sum type
    private ModulationType modulation;
}

