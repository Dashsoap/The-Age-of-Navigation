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
    signal input x1;
    signal input y1;
    signal input x2;
    signal input y2;
    signal input seed1;
    signal input seed2;
    signal input width;
    signal input height;

    signal output pub1;
    signal output pub2;
    signal output distMax;

    /* check abs(x1), abs(y1), abs(x2), abs(y2) < 2 ** 32 */
    component rp = MultiRangeProof(4, 40, 2 ** 32);
    rp.in[0] <== x1;
    rp.in[1] <== y1;
    rp.in[2] <== x2;
    rp.in[3] <== y2;

    /* check x < width && y < height */

    component comp = LessThan(32);
    comp.in[0] <== x2;
    comp.in[1] <== width;
    comp.out === 1;
    component comp1 = LessThan(32);
    comp1.in[0] <== y2;
    comp1.in[1] <== height;
    comp1.out === 1;

    /* check (x1-x2)^2 + (y1-y2)^2 <= distMax^2 */

    signal diffX;
    diffX <== x1 - x2;
    signal diffY;
    diffY <== y1 - y2;

    signal firstDistSquare;
    signal secondDistSquare;
    firstDistSquare <== diffX * diffX;
    secondDistSquare <== diffY * diffY;
    distMax <== firstDistSquare + secondDistSquare;

    /* check MiMCSponge(x1,y1) = pub1, MiMCSponge(x2,y2) = pub2 */
    /*
        220 = 2 * ceil(log_5 p), as specified by mimc paper, where
        p = 21888242871839275222246405745257275088548364400416034343698204186575808495617
    */
    component mimc1 = MiMCSponge(2, 220, 1);
    component mimc2 = MiMCSponge(2, 220, 1);

    mimc1.ins[0] <== x1;
    mimc1.ins[1] <== y1;
    mimc1.k <== seed1;
    mimc2.ins[0] <== x2;
    mimc2.ins[1] <== y2;
    mimc2.k <== seed2;

    pub1 <== mimc1.outs[0];
    pub2 <== mimc2.outs[0];
}

component main { public [seed1, seed2, width, height] } = Main();