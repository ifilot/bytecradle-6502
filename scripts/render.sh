#!/bin/bash

#
# This script produces a high-quality render of the PCB, both front and
# back side.
#

docker run --rm \
-v `pwd`:/workspace \
-w /workspace \
kicad/kicad:8.0.8 \
kicad-cli pcb export vrml --output /workspace/board.wrl /workspace/pcb/single-board/bytecradle-6502-single-board.kicad_pcb

head -1 "board.wrl" > "board.front.wrl"
cat <<EOF >> "board.front.wrl"
Transform {
    children [
        DirectionalLight {
            on TRUE
            intensity 0.63
            ambientIntensity 0.21
            color 1.0 1.0 1.0
            direction 0.1 -0.1 -1
        }
EOF
cat "board.wrl" >> "board.front.wrl"
echo "] }" >> "board.front.wrl"

head -1 "board.wrl" > "board.back.wrl"
cat <<EOF >> "board.back.wrl"
Transform {
    children [
        DirectionalLight {
            on TRUE
            intensity 0.63
            ambientIntensity 0.21
            color 1.0 1.0 1.0
            direction 0.1 0.1 1
        }
EOF
cat "board.wrl" >> "board.back.wrl"
echo "] }" >> "board.back.wrl"

rayhunter classic 7 \
    4320 4320 \
    "board.front.wrl" \
    "img/board.front.png" \
    --camera-pos 0 0 6 \
    --camera-dir 0 0 -1 \
    --scene-bg-color 1 1 1

rayhunter classic 7 \
    4320 4320 \
    "board.back.wrl" \
    "img/board.back.png" \
    --camera-pos 0 0 -6 \
    --camera-dir 0 0 1 \
    --scene-bg-color 1 1 1

convert \
    "img/board.front.png" \
    -trim \
    -resize 1060x1060 -normalize -density 600 \
    -bordercolor white -border 10 \
    -gravity center -extent 1080x1080 \
    "img/board-front.jpg"

convert \
    "img/board.back.png" \
    -trim \
    -resize 1060x1060 -normalize -density 600 \
    -bordercolor white -border 10 \
    -gravity center -extent 1080x1080 \
    "img/board-back.jpg"