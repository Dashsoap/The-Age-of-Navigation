pragma circom 2.0.0;

/*
    Prove: I know (x1,y1,x2,y2,p2,r2,distMax) such that:
    - x2^2 + y2^2 <= r^2
    - perlin(x2, y2) = p2
    - (x1-x2)^2 + (y1-y2)^2 <= distMax^2
    - MiMCSponge(x1,y1) = pub1
    - MiMCSponge(x2,y2) = pub2
*/

include "../../../node_modules/circomlib/circuits/mimcsponge.circom";
include "../../../node_modules/circomlib/circuits/comparators.circom";
include "../range_proof/circuit.circom";
// include "../perlin/compiled.circom";

template Main() {
    signal input x;
    signal input y;
    signal input width;
    signal input height;

    signal output pub;

    /* check abs(x), abs(y) < 2 ** 32 */
    component rp = MultiRangeProof(2, 40, 2 ** 32);
    rp.in[0] <== x;
    rp.in[1] <== y;

    /* check x < width && y < height */

    component comp = LessThan(32);
    comp.in[0] <== x;
    comp.in[1] <== width;
    comp.out === 1;
    component comp1 = LessThan(32);
    comp1.in[0] <== y;
    comp1.in[1] <== height;
    comp1.out === 1;

    /* check MiMCSponge(x,y, 0) = pub */
    /*
        220 = 2 * ceil(log_5 p), as specified by mimc paper, where
        p = 21888242871839275222246405745257275088548364400416034343698204186575808495617
    */
    component mimc = MiMCSponge(2, 220, 1);

    mimc.ins[0] <== x;
    mimc.ins[1] <== y;
    mimc.k <== 0;

    pub <== mimc.outs[0];
}

component main { public [width, height] } = Main();