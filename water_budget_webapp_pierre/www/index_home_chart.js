// COLORS: BLUE - #182856, GREEN - #00afa8, RED - #E55E69, DARK GRAY - #656565, LIGHT GRAY - #a9a9a9
// HOW TO GENERATE HOME D3 CHART AS AN IMAGE
// Step 1: Ran "index_home_chart.html"
// Step 2: Right clicked the bottom d3 graphic and save it as "home_d3.svg" in the www folder

const data = {
    "name": "Jurisdiction",
    "color": "#182856",
    "children": [
        {
            "name": "Component",
            "color": "#E55E69",
            "children": [
                {
                    "name": "Estimation Method",
                    "color": "#E55E69",
                    "children": [
                        {
                            "name": "Parameter",
                            "color": "#E55E69",
                            "children": [
                                {
                                    "name": "Data Source",
                                    "color": "#a9a9a9"
                                }
                            ]
                        }
                    ]
                },
                {
                    "name": "Flow Type",
                    "color": "#E55E69",
                    "children": [
                        {
                            "name": "Inflow",
                            "color": "#a9a9a9"
                        },
                        {
                            "name": "Internal Transfer",
                            "color": "#a9a9a9"
                        },
                        {
                            "name": "Outflow",
                            "color": "#a9a9a9"
                        }
                    ]
                },
                {
                    "name": "Flow Source",
                    "color": "#E55E69",
                    "children": [
                        {
                            "name": "Atmosphere",
                            "color": "#a9a9a9"
                        },
                        {
                            "name": "External Groundwater",
                            "color": "#a9a9a9"
                        },
                        {
                            "name": "External Surface Water",
                            "color": "#a9a9a9"
                        },
                        {
                            "name": "Zone Groundwater",
                            "color": "#a9a9a9"
                        },
                        {
                            "name": "Zone Land System",
                            "color": "#a9a9a9"
                        },
                        {
                            "name": "Zone Surface Water",
                            "color": "#a9a9a9"
                        }
                    ]
                },
                {
                    "name": "Flow Sink",
                    "color": "#E55E69",
                    "children": [
                        {
                            "name": "Atmosphere",
                            "color": "#a9a9a9"
                        },
                        {
                            "name": "External Groundwater",
                            "color": "#a9a9a9"
                        },
                        {
                            "name": "External Surface Water",
                            "color": "#a9a9a9"
                        },
                        {
                            "name": "Zone Groundwater",
                            "color": "#a9a9a9"
                        },
                        {
                            "name": "Zone Land System",
                            "color": "#a9a9a9"
                        },
                        {
                            "name": "Zone Surface Water",
                            "color": "#a9a9a9"
                        }
                    ]
                },
                {
                    "name": "Subcomponent",
                    "color": "#E55E69",
                    "children": [
                        {
                            "name": "Component",
                            "color": "#a9a9a9"
                        }
                    ]
                },
                {
                    "name": "Partial Subcomponent",
                    "color": "#E55E69",
                    "children": [
                        {
                            "name": "Component",
                            "color": "#a9a9a9"
                        }
                    ]
                },
                {
                    "name": "Exact Match",
                    "color": "#E55E69",
                    "children": [
                        {
                            "name": "Component",
                            "color": "#a9a9a9"
                        }
                    ]
                }

            ]
        }
    ]
} 

console.log(data);

// set dimensions
var margin = {top: 1, right: 50, bottom: 50, left: 50};
var width = 1100 - margin.left - margin.right;
var height = 800 - margin.top - margin.bottom; 

// add svg on which d3 will be made
var svg = d3.select("#home_container")
    .append("svg")
        .attr("height", height + margin.top + margin.bottom)
        .attr("width", width + margin.left + margin.right)
    .append("g")
        .attr("transform", "translate(" + (margin.left) + "," + margin.top + ")");

// Background rectangle 
svg.append("rect")
.attr("width", width + margin.right + margin.left)
.attr("height", height + margin.top + margin.bottom)
.attr("transform", "translate(" + - margin.left  + "," + - (margin.top + 10) + ")")
.attr("fill", "#F8F8F8")
.attr('rx', 20);

// set rectangle dimensions
box_width = 150;
box_height = 30;

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
nodes.forEach(d => {d.y = d.depth * 200}); //d.y dictates how much tree unfolds in x axis distance because it is a horizontal tree, if it was vertical d.y would affect y axis

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

var node = svg.selectAll('g.node')
    .data(nodes)
    .enter().append('g')
    .attr("class", function(d) {
        return "node" + 
        (d.children ? " node--internal" : " node--leaf"); })
    .attr('transform', d => { return "translate(" + d.y + "," + d.x + ")"})

// NODES *********************************************
// add rectangle for the nodes
node.append('rect')
    .attr('class', 'node')
    .attr('width', box_width)
    .attr('height', box_height)
    .attr('rx', 6)
    .attr('ry', 6)
//   .attr("x", function(d) { return d.children || d._children ? -60 : 26; })
//	 .attr("y", function(d) { return d.children || d._children ? 15 : 15; })
    //.style("fill", "#E55E69" )
    .style("fill", d => { return d.data.color;});

// ADD LABELS FOR THE NODES
node.append('text')
    .attr("dy", "0.35em")
    .attr("x", box_width/2)
    .attr("y", box_height/2) 
    .attr("text-anchor", "middle")
    .text(function(d) { return d.data.name; })
    .attr("font-size", "12")
    .style("font-family", "arial")
    .style("fill", "#ffffff")
    .style("font-weight", "bold")
    // .style("word-break", "normal");


/////////// Save d3 chart as svg
var doctype = '<?xml version="1.0" standalone="no"?>'
  + '<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">';

// serialize our SVG XML to a string.
var source = (new XMLSerializer()).serializeToString(d3.select('svg').node());

// create a file blob of our SVG.
var blob = new Blob([ doctype + source], { type: 'image/svg+xml;charset=utf-8' });

var url = window.URL.createObjectURL(blob);

// Put the svg into an image tag so that the Canvas element can read it in.
var img = d3.select('body').append('img')
 .attr('width', width)
 .attr('height', height)
 .node();


img.onload = function(){
  // Now that the image has loaded, put the image into a canvas element.
  var canvas = d3.select('body').append('canvas').node();
  canvas.width = width;
  canvas.height = height;
  var ctx = canvas.getContext('2d');
  ctx.drawImage(img, 0, 0);
  var canvasUrl = canvas.toDataURL("image/png");
  var img2 = d3.select('body').append('img')
    .attr('width', width)
    .attr('height', height)
    .node();
  // this is now the base64 encoded version of our PNG! you could optionally 
  // redirect the user to download the PNG by sending them to the url with 
  // `window.location.href= canvasUrl`.
  img2.src = canvasUrl; 
}
// start loading the image.
img.src = url;

