//   http://plnkr.co/edit/LnuoQY7R0tDWR4EnW1Rg?p=preview&preview


const data = {
    "name": "Jurisdiction",
    "children": [
        {
            "name": "Component",
            "children": [
                {
                    "name": "Estimation Method",
                    "children": [
                        {
                            "name": "Parameter",
                            "children": [
                                {
                                    "name": "Data Source"
                                }
                            ]
                        }
                    ]
                },
                {
                    "name": "Flow Type"
                },
                {
                    "name": "Flow Source"
                },
                {
                    "name": "Flow Sink"
                },
                {
                    "name": "Subcomponent of"
                },
                {
                    "name": "Partial Subcomponent of"
                },
                {
                    "name": "Exact Match"
                }

            ]
        }
    ]
} 

console.log(data);

// set dimensions
var margin = {top: 50, right: 50, bottom: 50, left: 50};
var width = 1200 - margin.left - margin.right;
var height = 500 - margin.top - margin.bottom; 

// set rectangle dimensions
box_width = 150;
box_height = 30;

// add svg on which d3 will be made

var svg = d3.select("#home_container")
    .append("svg")
        .attr("height", height + margin.top + margin.bottom)
        .attr("width", width + margin.left + margin.right)
    .append("g")
        .attr("transform", "translate(" + margin.left + "," + (margin.top + 30) + ")");


// create cluster layout
var tree = d3.tree()
    .size([height, width])
    .separation((a,b) => {return a.parent === b.parent ? 1:1;});

// sending data to tree layout
root = d3.hierarchy(data, function(d){
    return d.children;
}) 

// x and y node positions
var treeData = tree(root);

// assigning nodes and links to separate variables
var nodes = treeData.descendants();
var links = treeData.descendants().slice(1);

//Normalizing for fixed depth
nodes.forEach(d => {d.y = d.depth * 235}); //d.y dictates how much tree unfolds in x axis distance because it is a horizontal tree, if it was vertical d.y would affect y axis

//LINKS***************************************
var link = svg.selectAll('path.link')
.data(links, function(d) { return d.id; })
.enter().append('path')
    .attr("class", "link")
    .attr("fill", "none")   // without this its gonna fill all black
    .attr("stroke", "#ccc") // for the black line connecting nodes
    .attr('d', function(d) {
        return "M" + d.y  + "," + (d.x + box_height/2)
        + "C" + (d.parent.y + 170) + "," + (d.x + box_height/2)
        + " " + (d.parent.y + 160) + "," + (d.parent.x + box_height/2) 
        + " " + (d.parent.y + box_width) + "," + (d.parent.x + box_height/2);
    });

    console.log(links)
    // changing M y changes x axis

var node = svg.selectAll('g.node')
    .data(nodes)
    .enter().append('g')
    .attr("class", function(d) {
        return "node" + 
        (d.children ? " node--internal" : " node--leaf"); })
    .attr('transform', d => { return "translate(" + d.y + "," + d.x + ")"})

// NODES *********************************************
// add circle for the nodes
node.append('rect')
    .attr('class', 'node')
    .attr('width', box_width)
    .attr('height', box_height)
    .attr('rx', 6)
    .attr('ry', 6)
//   .attr("x", function(d) { return d.children || d._children ? -60 : 26; })
//	 .attr("y", function(d) { return d.children || d._children ? 15 : 15; })
    .style("fill", "#E55E69" )
    //.style("fill", d => {return d._children ? "blue" : "#fff";}) //before merging

// ADD LABELS FOR THE NODES
node.append('text')
    .attr("dy", "0.35em")
    .attr("x", box_width/2)
    .attr("y", box_height/2) 
    .attr("text-anchor", "middle")
    .text(function(d) { return d.data.name; })
    .attr("font-size", "11")
    .style("font-family", "arial")
    .style("fill", "#ffffff")
    .style("font-weight", "bold")
    // .style("word-break", "normal");




    // // return "M" + d.y  + "," + (d.x + box_height/2)
    // + "C" + (d.parent.y + 50) + "," + (d.x + box_height/2)
    // + " " + (d.y + box_width + 50) + "," + (d.parent.x + box_height/2) 
    // + " " + d.parent.y + "," + (d.parent.x + box_height/2);