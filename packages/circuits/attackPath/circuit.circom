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
    signal input xs[10];
    signal input ys[10];
    signal input seeds[10];
    signal input width[10];
    signal input height[10];

    signal output pubs[10];
    signal output distMax[10];

    /* check abs(x1), abs(y1), abs(x2), abs(y2) < 2 ** 32 */
    component rp = MultiRangeProof(20, 40, 2 ** 32);
    component comp[10];
    component comp1[10];
    component mimc[10];
    signal diffX[10];
    signal diffY[10];
    signal firstDistSquare[10];
    signal secondDistSquare[10];
    for (var i = 0; i < 10; i++) {
        rp.in[i * 2] <== xs[i];
        rp.in[i * 2 + 1] <== ys[i];
        /* check x < width && y < height */

        comp[i] = LessThan(32);
        comp[i].in[0] <== xs[i];
        comp[i].in[1] <== width[i];
        comp[i].out === 1;
        comp1[i] = LessThan(32);
        comp1[i].in[0] <== ys[i];
        comp1[i].in[1] <== height[i];
        comp1[i].out === 1;
        /* check (x1-x2)^2 + (y1-y2)^2 <= distMax^2 */

        diffX[i] <== xs[0] - xs[i];
        diffY[i] <== ys[0] - ys[i];
        firstDistSquare[i] <== diffX[i] * diffX[i];
        secondDistSquare[i] <== diffY[i] * diffY[i];
        distMax[i] <== firstDistSquare[i] + secondDistSquare[i];

        mimc[i] = MiMCSponge(2, 220, 1);

        mimc[i].ins[0] <== xs[i];
        mimc[i].ins[1] <== ys[i];
        mimc[i].k <== seeds[i];

        pubs[i] <== mimc[i].outs[0];
    }
}

component main { public [seeds, width, height] } = Main();