module StackTheme {
    const BG = 0x000000;
    const TEXT = 0xF6F7F8;
    const DATA = 0xC8CCCE;
    const EMPTY = 0x202124;
    const BLOCK_LOW = 0x0A0C0C;
    const BLOCK_MID = 0x111515;
    const BLOCK_HIGH = 0x181E1E;

    // Canonical colors sampled from trainer-boi-full-color.svg.
    const CYAN = 0x02BCC0;
    const BRIGHT_BLUE = 0x0CB9FC;
    const BLUE = 0x0A66DA;
    const YELLOW = 0xFCBC12;
    const ORANGE = 0xFC9809;
    const RED = 0xFD4E2E;
    const LIME = 0x65FC04;
    const GREEN_1 = 0x07552C;
    const GREEN_2 = 0x087137;
    const GREEN_3 = 0x0A8D3C;
    const GREEN_4 = 0x10AA40;
    const GREEN_5 = 0x20C943;
    const GREEN_6 = 0x3BE846;
    const PURPLE = 0x8537DF;
    const DEEP_PURPLE = 0x4C229E;

    // The AOD reference uses one subdued neutral throughout.
    const AOD = 0xA4A8AB;
    const AOD_FAINT = 0x34383A;

    function palette(index) {
        if (index == 1) { return BRIGHT_BLUE; }
        if (index == 2) { return BLUE; }
        if (index == 3) { return YELLOW; }
        if (index == 4) { return ORANGE; }
        if (index == 5) { return RED; }
        if (index == 6) { return LIME; }
        if (index == 7) { return PURPLE; }
        if (index == 8) { return DEEP_PURPLE; }
        if (index == 9) { return TEXT; }
        return CYAN;
    }
}
