package tc.catseye.whothm;

import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;

abstract class Command {
    public abstract void execute(Machine m);
}

class DrawCommand extends Command {
    private Rectangle r;
    private TruthTable tt;

    public DrawCommand(Rectangle r, TruthTable tt) {
        this.r = r;
        this.tt = tt;
    }

    public void execute(Machine m) {
        r.draw(m.bitmap, tt);
    }
    
    public String toString() {
        return "DrawCommand(r=" + r.toString() + ",tt=" + tt.toString() + ")";
    }
}

class DeltaCommand extends Command {
    private Rectangle r;
    private String memberName;
    private int delta;

    public DeltaCommand(Rectangle r, String memberName, int delta) {
        this.r = r;
        this.memberName = memberName;
        this.delta = delta;
    }

    public void execute(Machine m) {
        r.deltaMember(memberName, delta);
    }

    public String toString() {
        return "DeltaCommand(r=" + r.toString() + ",m=" + memberName + ",d=" + delta + ")";
    }
}

class DeltaIndirectCommand extends Command {
    private Rectangle destRect, srcRect;
    private String destMember, srcMember;

    public DeltaIndirectCommand(Rectangle destRect, String destMember,
                                Rectangle srcRect, String srcMember) {
        this.destRect = destRect;
        this.destMember = destMember;
        this.srcRect = srcRect;
        this.srcMember = srcMember;
    }

    public void execute(Machine m) {
        destRect.deltaMember(destMember, srcRect.getMember(srcMember));
    }

    public String toString() {
        return "DeltaIndirectCommand(srcR=" + srcRect.toString() + ",srcM=" + srcMember +
                                   ",destR=" + destRect.toString() + ",destM=" + destMember + ")";
    }
}

public class Machine {
    public BitMap bitmap;
    private ArrayList<Command> commands;

    public Machine() {
        this.bitmap = null;
        commands = new ArrayList<Command>();
    }
 
    public void addDrawCommand(Rectangle r, TruthTable tt) {
        commands.add(new DrawCommand(r, tt));
    }

    public void addDeltaCommand(Rectangle r, String memberName, int delta) {
        commands.add(new DeltaCommand(r, memberName, delta));
    }

    public void addDeltaIndirectCommand(Rectangle destRect, String destMember,
                                        Rectangle srcRect, String srcMember) {
        commands.add(new DeltaIndirectCommand(destRect, destMember,
                                              srcRect, srcMember));
    }

    public void run(BitMap bitmap) {
        this.bitmap = bitmap;
        for (int i = 0; i < 100; i++) {
            for (Command c : commands) {
                c.execute(this);
            }
        }
    }

    public String toString() {
        String k = "Machine(\n";
        for (Command c : commands) {
            k += "  " + c.toString() + "\n";
        }
        return k + ")";
    }
}
