pragma circom 2.0.0;

/*
    Prove: I know (x,y,seed) such that:
    - x^2 + y^2 <= r^2
    - perlin(x, y, seed) = p
    - MiMCSponge(x,y) = pub
*/

include "../../../node_modules/circomlib/circuits/mimcsponge.circom";
include "../../../node_modules/circomlib/circuits/comparators.circom";
include "../range_proof/circuit.circom";
include "../perlin/perlin.circom";

template Main() {
    signal input x;
    signal input y;
    signal input terrainSeed;
    signal input fogSeed;
    signal input resourceSeed;
    signal input terrainPerlin;
    signal input resourcePerlin;
    signal input width;
    signal input height;

    signal output realCoord;
    signal output fogCoord;

    /* check abs(x), abs(y), abs(r) < 2^32 */
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

    /* check MiMCSponge(x,y) = pub */
    /*
        220 = 2 * ceil(log_5 p), as specified by mimc paper, where
        p = 21888242871839275222246405745257275088548364400416034343698204186575808495617
    */
    component mimc = MiMCSponge(2, 220, 1);

    mimc.ins[0] <== x;
    mimc.ins[1] <== y;
    mimc.k <== 0;

    realCoord <== mimc.outs[0];

    component mimc1 = MiMCSponge(2, 220, 1);

    mimc1.ins[0] <== x;
    mimc1.ins[1] <== y;
    mimc1.k <== fogSeed;

    fogCoord <== mimc1.outs[0];

    /* check perlin(x, y, resourceSeed) = p */
    /* component perlin = MultiScalePerlin();
    perlin.p[0] <== x;
    perlin.p[1] <== y;
    perlin.KEY <== resourceSeed;
    perlin.SCALE <== 2;
    perlin.xMirror <== 0;
    perlin.yMirror <== 0;
    resourcePerlin === perlin.out; */

    /* check perlin(x, y, Seed) = tp */
    /* component perlin1 = MultiScalePerlin();
    perlin1.p[0] <== x;
    perlin1.p[1] <== y;
    perlin1.KEY <== terrainSeed;
    perlin1.SCALE <== 2;
    perlin1.xMirror <== 0;
    perlin1.yMirror <== 0;
    terrainPerlin === perlin1.out; */
}

component main { public [terrainSeed, fogSeed, resourceSeed, terrainPerlin, resourcePerlin, width, height] } = Main();