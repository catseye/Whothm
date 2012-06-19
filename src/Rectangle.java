package tc.catseye.whothm;

class Rectangle {
    private int x, y, w, h;

    Rectangle(int x, int y, int w, int h) {
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
    }

    int getMember(String member) {
        if (member.equals("x")) return this.x;
        if (member.equals("y")) return this.y;
        if (member.equals("w")) return this.w;
        if (member.equals("h")) return this.h;
        return 0;
    }

    void deltaMember(String member, int delta) {
        if (member.equals("x")) this.x += delta;
        if (member.equals("y")) this.y += delta;
        if (member.equals("w")) this.w += delta;
        if (member.equals("h")) this.h += delta;
    }

    public void draw(BitMap b, TruthTable t) {
        if (this.x > b.getWidth() && this.x + this.w > b.getWidth() &&
            this.y > b.getHeight() && this.y + this.h > b.getHeight())
            return;
        int right = this.x + this.w;
        if (right > b.getWidth()) right = b.getWidth();
        int bottom = this.y + this.h;
        if (bottom > b.getHeight()) bottom = b.getHeight();

        for (int y = this.y; y < bottom; y++) {
            for (int x = this.x; x < right; x++) {
                b.modifyPixel(x, y, t);
            }
        }
    }

    public String toString() {
        return "Rectangle(" + x + "," + y + "," + w + "," + h + ")";
    }
}
