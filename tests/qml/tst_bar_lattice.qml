import QtQuick
import QtTest
import "../../src/surfaces/bar/Lattice.js" as Lattice

TestCase {
    name: "BarLattice"
    function test_workspaceCentersShareBackgroundGrid_data() {
        return [
            {
                tag: "top",
                edge: "top"
            },
            {
                tag: "bottom",
                edge: "bottom"
            },
            {
                tag: "left",
                edge: "left"
            },
            {
                tag: "right",
                edge: "right"
            }
        ];
    }
    function test_workspaceCentersShareBackgroundGrid(data) {
        const spacing = 18;
        const reserve = 36;
        const visual = 72;
        const reverse = data.edge === "bottom" || data.edge === "right";
        const groupStart = reverse ? visual - reserve : 0;
        const cross = groupStart + Lattice.crossCellOffset(data.edge, reserve, spacing) + spacing / 2;
        const distanceFromEdge = reverse ? visual - cross : cross;
        compare((distanceFromEdge - spacing / 2) % spacing, 0);
        const groupAlong = Lattice.snapStart(314, spacing);
        for (let i = 0; i < 5; i++) {
            const along = groupAlong + Lattice.node(i + 1, spacing);
            compare((along - spacing / 2) % spacing, 0);
        }
    }
    function test_replacedDotIsSuppressedOnlyAtItsNode() {
        const nodes = [
            {
                x: 27,
                y: 27
            }
        ];
        compare(Lattice.isOccupied(27, 27, nodes), true);
        compare(Lattice.isOccupied(45, 27, nodes), false);
        compare(Lattice.isCovered(45, 27, [
            {
                x: 36,
                y: 20,
                width: 20,
                height: 12
            }
        ]), true);
        compare(Lattice.isCovered(27, 27, [
            {
                x: 36,
                y: 20,
                width: 20,
                height: 12
            }
        ]), false);
    }
    function test_ordinaryDotsBracketActionableWorkspaces() {
        const actionable = [
            {
                x: 27,
                y: 27
            },
            {
                x: 45,
                y: 27
            }
        ];
        compare(Lattice.isOccupied(9, 27, actionable), false);
        compare(Lattice.isOccupied(27, 27, actionable), true);
        compare(Lattice.isOccupied(45, 27, actionable), true);
        compare(Lattice.isOccupied(63, 27, actionable), false);
    }
    function test_workspaceStartsOneNodeInAndContentUsesSecondRow() {
        for (const edge of ["top", "bottom", "left", "right"]) {
            compare(Lattice.node(0, 18), 9);
            compare(Lattice.node(1, 18), 27);
            const crossCenter = Lattice.contentCrossOffset(edge, 36, 18, 20) + 10;
            compare(crossCenter, edge === "bottom" || edge === "right" ? 9 : 27);
        }
    }
}
