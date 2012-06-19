package tc.catseye.whothm;

import java.awt.Color;
import java.awt.Graphics;
import java.awt.Rectangle;

import javax.swing.JViewport;

public class Canvas extends JViewport {
    private BitMap bm;

    public Canvas(BitMap bm) {
        this.bm = bm;
    }

    public void paint(Graphics g) {
        g.setColor(Color.yellow);
        Rectangle r = g.getClipBounds();
        g.fillRect(r.x, r.y, r.width, r.height);
        bm.render(g);
    }
}
