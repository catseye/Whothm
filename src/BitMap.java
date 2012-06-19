package tc.catseye.whothm;

import java.awt.Color;
import java.awt.Graphics;
import java.util.ArrayList;

public class BitMap {
    /*
     * An object that represents a bit map.  The interpretation 
     * of such an object can be rendered to a graphics context.
     */
    private ArrayList<Boolean> bitmap;
    private int width;
    private int height;
    private int pixel_width;
    private int pixel_height;

    public BitMap() {
        this.width = 128;
        this.height = 128;
        this.pixel_width = 5;
        this.pixel_height = 5;
        clear();
    }

    public void clear() {
        this.bitmap = new ArrayList<Boolean>(this.width * this.height);
        for (int i = 0; i < this.width * this.height; i++) {
            this.bitmap.add(false);
        }
    }

    public int getHeight() {
        return height;
    }

    public int getWidth() {
        return width;
    }

    public void alterWidth(int delta) {
        int newWidth = width + delta;

        if (newWidth < 1)
            newWidth = 1;

        width = newWidth;
    }

    public void alterHeight(int delta) {
        int newHeight = height + delta;
        
        if (newHeight < 1)
            newHeight = 1;

        height = newHeight;
    }

    public void alterPixelSize(int delta) {
        int newHeight = pixel_height + delta;
        
        if (newHeight < 1)
                newHeight = 1;

        pixel_height = newHeight;
        pixel_width = newHeight;
    }

    public void modifyPixel(int x, int y, TruthTable t) {
        int pos = (y * this.width) + x;
        if (x < this.width && y < this.height) {
            this.bitmap.set(pos, t.apply(this.bitmap.get(pos), true));
        }
    }

    public void render(Graphics g) {
        //Draw the bitmap seen by this BitMap into the given Graphics context.

        int row = 0, column = 0;

        while (row < this.height) {
            column = 0;
            while (column < this.width) {
                // get pixel.
                int pos = (row * this.width) + column;
                if (pos < this.bitmap.size()) {
                    Color c = null;
                    if (this.bitmap.get(pos)) {
                        c = new Color(0, 0, 0);
                    } else {
                        c = new Color(255, 255, 255);
                    }
                    g.setColor(c);
                    g.fillRect(column * this.pixel_width, row * this.pixel_height,
                            this.pixel_width, this.pixel_height);
                } else {
                    g.setColor(Color.black);
                    g.drawLine(
                        (column + 1) * this.pixel_width, row * this.pixel_height,
                        (column) * this.pixel_width, (row + 1) * this.pixel_height
                    );
                }
                column++;
            }
            row++;
        }
    }

    public void dump() {
        System.out.println("Bitmap width: " + width);
    }

}
