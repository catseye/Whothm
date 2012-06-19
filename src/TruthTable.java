package tc.catseye.whothm;

import java.util.Set;
import java.util.HashSet;

class TruthTable {
    Set<String> tt;

    TruthTable() {
        tt = new HashSet<String>();
    }
    
    void mapToTrue(String truthPair) {
        tt.add(truthPair);
    }
    
    boolean apply(boolean a, boolean b) {
        String target = (a ? "T" : "F") + (b ? "T" : "F");
        return tt.contains(target);
    }

    public String toString() {
        return "TruthTable(" + tt.toString() + ")";
    }

}
