/////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////// sending nested json from R
/////////////////////////////////////////////////////////////////////////////////

var leaf_nodes_1;

Shiny.addCustomMessageHandler("search_height",
function(message) {
    leaf_nodes_1 = message;
})

Shiny.addCustomMessageHandler("search_json",
function (message) {
    
    d3.selectAll("svg").remove();
    //d3.select("svg_sticky").remove();

    var data = message;

    var margin = {top: 25, right: 50, bottom: 20, left: 50}
    var width = 1050 - margin.left - margin.right //change width because leaf nodes were going out
    var height = (leaf_nodes_1*35) - margin.top - margin.bottom; //1200 height for about 40 leaf nodes

    // appending svg object to the body div "container"
    var svg = d3.select("#search_container")   /////////changed Id, removed autoscroll and reduced 1 label level option
        .append("svg")
            .attr("width", width + margin.right + margin.left)
            .attr("height", d => { return leaf_nodes_1 < 3 ? height + margin.top + margin.bottom + 150 : height + margin.top + margin.bottom + 30 ;})
        .append("g")
            .attr("transform", "translate(" + margin.left + "," + (margin.top + 30) + ")");

    // Background rectangle
    svg.append("rect")
    .attr("width", width + margin.right + margin.left)
    .attr("height", d => { return leaf_nodes_1 < 3 ? height + 150 : height + margin.top + margin.bottom  ;} )
    .attr("transform", "translate(" + - margin.left  + "," + - (margin.top + 10) + ")")
    .attr("fill", "#F8F8F8")
    .attr('rx', 20);
    
    var i = 0;

    // adjusting height dynamizally
    if (leaf_nodes_1 < 3) {
        var treeHeight = height + 100;
    }
    else {
        var treeHeight = height;
    }

    // Create the cluster layout:
    var tree = d3.tree()
        .size([treeHeight, width]) 
        .separation((a,b) => {return a.parent == b.parent ? 1 : 1;}); // for separating nodes nicely vertically
    
    // Give the data to the tree layout:
    root = d3.hierarchy(data, function(d) {
        return d.children;
    });
    //root.x0 = leaf_nodes_1 <3 ? (height + 100) / 2 : height / 2 ;
    
        // x and y position for nodes;
        var treeData = tree(root);
        
        // compute the new tree layout
        var nodes = treeData.descendants()
        var links = treeData.descendants().slice(1);

        //Normalizing for fixed depth
        nodes.forEach(d => {d.y = d.depth * 235}); //d.y dictates how much tree unfolds in x axis distance because it is a horizontal tree, if it was vertical d.y would affect y axis

        // Adding labels for each level
        // using underscore.js library
        var level_labels = ["", "Estimation Method", "Parameter", "Data Source"]
        var depthOrder = _.uniq(_.pluck(nodes, "depth")).sort();
        var label_data = [];
        for (var n in depthOrder){
            label_data[n] = {
                id: parseInt(n),
                label: level_labels[n]
            };
        }
        
        svg.selectAll("g.levels-svg").remove();
        var levelSVG = svg.append("g").attr("class", "levels-svg");
        var levels =  levelSVG.selectAll("g.level");
        levels.data(label_data)
             .enter().append("g")
             .attr("class", "level")
             .attr("transform", function(d) { return "translate(" + d.id*235 + "," + -10 + ")"; })
             .append("text")
             .text(function(d){
                 return d.label;
             })
             //.attr("x", -40)
             .attr("x", function(d) {
                return d.label === "Estimation Method" ? -65 : -40;})
             .attr("y", 0)
             .attr("font-family","arial")
             .style("font-weight", "bold")
             .style("fill", "#777777")
            //  .transition().duration(duration)
            //  .attr("fill-opacity", 1)
        
        //LINKS***************************************
        var link = svg.selectAll('path.link')
            .data(links, function(d) { return d.id; })
            .enter().append('path')
                .attr("class", "link")
                .attr("fill", "none")   // without this its gonna fill all black
                .attr("stroke", "#ccc") // for the black line connecting nodes
                .attr('d', function(d) {
                    return "M" + d.y + "," + d.x
                    + "C" + (d.parent.y + 20) + "," + d.x
                    + " " + (d.parent.y + 10) + "," + d.parent.x
                    + " " + d.parent.y + "," + d.parent.x;
                });
        
        var node = svg.selectAll('g.node')
            .data(nodes)
            .enter().append('g')
            .attr("class", function(d) {
                return "node" + 
                (d.children ? " node--internal" : " node--leaf"); })
            .attr('transform', d => { return "translate(" + d.y + "," + d.x + ")"})
        
        // NODES *********************************************
        // add circle for the nodes
        node.append('circle')
            .attr('class', 'node')
            .attr('r', 6.5) // before merging
            .style("fill", "#E55E69" )
            //.style("fill", d => {return d._children ? "blue" : "#fff";}) //before merging

        // ADD LABELS FOR THE NODES
        node.append('text')
            .attr("dy", "0.35em")
            .attr("x", function(d) {
                return d.children ? -13 : 13;})
            //.attr("y", -4) 
            .attr("text-anchor", function(d) {
                return d.children ? "end" : "start";
            })
            .text(function(d) { return d.data.name; })
            .call(wrap, 250)  // wrap text labels to 2 lines
            .attr("font-size", "11")
            .style("font-family", "arial")
            .style("fill", "#777777")
            .style("font-weight", "bold")
            .style("text-shadow", "-1px -1px 3px white, -1px 1px 3px white, 1px -1px 3px white, 1px 1px 3px white")
            // .style("word-break", "normal");
        
        function wrap(text, width) {
            text.each(function() {
                var text = d3.select(this),
                words = text.text().split(/\s+/).reverse(),
                word,
                line = [],
                lineNumber = 0,
                lineHeight = 1, // ems
                x = text.attr("x"),
                y = text.attr("y"),
                dy = parseFloat(text.attr("dy")),
                tspan = text.text(null).append("tspan").attr("x", x).attr("y", y).attr("dy", dy + "em"); // removed dy + em for making equal line spaces among nodes and leaf nodes
                while (word = words.pop()) {
                    line.push(word);
                    tspan.text(line.join(" "));
                    if (tspan.node().getComputedTextLength() > width) {
                        line.pop();
                        tspan.text(line.join(" "));
                        line = [word];
                        tspan = text.append("tspan").attr("x", x).attr("y", y).attr("dy", ++lineNumber * lineHeight + dy + "em").text(word);
                        
                    }
                }
            });

        } 

})


/////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////// sending nested json from R
/////////////////////////////////////////////////////////////////////////////////



var leaf_nodes_2;

Shiny.addCustomMessageHandler("state_height",
function(message) {
    leaf_nodes_2 = message;
})

Shiny.addCustomMessageHandler("state_json",
function (message) {

    // Loading csv containing URIs for each class (components, estimation methods etc.)
    // and then run the following code chunk
    d3.csv("hyperlink.csv").then(function(uri_data) {
        
        // Storing nested json data to 'data'
        var data = message;
        console.log(uri_data);
        //////////////////////////////////////////////////////
        ///////////////////// ADD URIs FROM CSV TO NESTED JSON 
        //////////////////////////////////////////////////////

        // Creating empty arrays for each class to hold all values from csv
        // and use them to create unique values
        var j_uri = [];
        var j_uri_unique = [];
        var c_uri = [];
        var c_uri_unique = [];
        var em_uri = [];
        var em_uri_unique = [];
        var p_uri = [];
        var p_uri_unique = [];
        var ds_uri = [];
        var ds_uri_unique = [];

        // Creating function to store each class elements in an array
        function createArray(array, uri, label) {
            uri_data.forEach(item => {
                var innerObj = {};
                innerObj[label] = item[label];
                innerObj[uri] = item[uri];
                array.push(innerObj);
            })
        }

        createArray(j_uri, 'j', 'jL');
        createArray(c_uri, 'c', 'cL');
        createArray(em_uri, 'em', 'emL');
        createArray(p_uri, 'p', 'pL');
        createArray(ds_uri, 'ds', 'dsL');

        // Creating function to extract unique values from previous arrays
        var j_map, c_map, em_map, p_map, ds_map;
        function createUniqueArray(array, unique_array, uri, label, map){
            map = new Map();
            for (const item of array){
                if(!map.has(item[label])){
                    map.set(item[label], true);
                    var innerObj = {};
                    innerObj[label] = item[label];
                    innerObj[uri] = item[uri];
                    unique_array.push(innerObj);
                }
            }
        }

        createUniqueArray(j_uri, j_uri_unique, 'j', 'jL', j_map);
        createUniqueArray(c_uri, c_uri_unique, 'c', 'cL', c_map);
        createUniqueArray(em_uri, em_uri_unique, 'em', 'emL', em_map);
        createUniqueArray(p_uri, p_uri_unique, 'p', 'pL', p_map);
        createUniqueArray(ds_uri, ds_uri_unique, 'ds', 'dsL', ds_map);

        // creating a function to add uri as a property to add to each children node
        function addURI(array, uri, label, item){
            if (uri === 'c'){
                for (const level_name in array){
                    if (array[level_name][label] === item["name"] + '-' + data["name"]) {
                        item["uri"] = array[level_name][uri]
                    }
                }
            } else {
                for (const level_name in array){
                    if (array[level_name][label] === item["name"]){
                        item["uri"] = array[level_name][uri]
                    }
                }
            }  
        }

        //adding uri as a property to each children node
        data["uri"] = "http://purl.org/iow/WaterBudgetingFramework#" + data["name"]
        //data["uri"] = "http://www.google.com";
        data.children.forEach(item2 => {
            addURI(c_uri_unique, 'c', 'cL', item2);
            //console.log(index);
            item2.children.forEach(item3 =>{
                addURI(em_uri_unique, 'em', 'emL', item3);
                item3.children.forEach(item4 => {
                    addURI(p_uri_unique, 'p', 'pL', item4);
                    item4.children.forEach(item5 => {
                        addURI(ds_uri_unique, 'ds', 'dsL', item5);
                    })
                })
            })
        })

        console.log(c_uri_unique)
        console.log(data)

        ////////////////////////////////////////////
        ///////////////////////////CREATING D3 CHART 
        ////////////////////////////////////////////



        d3.selectAll("svg").remove();

        var margin = {top: 25, right: 90, bottom: 20, left: 90}
        var width = 1300 - margin.left - margin.right //changed width because leaf nodes were going out
        var height = (leaf_nodes_2*30) - margin.top - margin.bottom; //1200 height for about 40 leaf nodes

        // appending svg object to the body div "container"
        var svg = d3.select("#state_container")   
            .append("svg")
                .attr("width", width + margin.right + margin.left)
                .attr("height", height + margin.top + margin.bottom)
            .append("g")
                .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

        // Background rectangle
        svg.append("rect")
        .attr("width", width + margin.right + margin.left)
        .attr("height", height + margin.top + margin.bottom)
        .attr("transform", "translate(" + - margin.left + "," + - margin.top + ")")
        .attr("fill", "#F8F8F8")
        .attr('rx', 20);

        // appending svg object to the body div "sticky"
        var svg_sticky = d3.select("#state_sticky")  
            .append("svg")
                .attr("width", width + margin.right + margin.left) //to extend white background of label levels
                .attr("height", 40)
            .append("g")
                .attr("transform", "translate(" + - 10 + "," + 35 + ")");

        var i = 0
        var duration = 750
        var root;

        // Auto-scroll
        var scrollCount = 1;
        while (scrollCount < 2) {
            autoscroll();
            scrollCount++ ;
        } 
            
        // Create the cluster layout:
        var tree = d3.tree()
            .size([height,width]) 
            .separation((a,b) => {return a.parent == b.parent ? 1 : 1;}); // for separating nodes nicely

        // Give the data to the tree layout:
        root = d3.hierarchy(data, function(d) {
            return d.children;
        });
        root.x0 = height / 2;
        root.y0 = 0;

        // Collapse after the second level
        root.children.forEach(collapse); // by default collapse level
        //tree.nodes(root).forEach(function(n) { toggle(n); });
        collapse(root); // to have it at the first level by default
        update(root);

        // Collapse the node and all it's children
        function collapse(d) {
            if (d.children) {
                d._children = d.children
                d._children.forEach(collapse)
                d.children = null
            }
        }

        function update(source) {
            // x and y position for nodes;
            var treeData = tree(root);
            
            // compute the new tree layout
            var nodes = treeData.descendants()
            var links = treeData.descendants().slice(1);

            //Normalizing for fixed depth
            nodes.forEach(d => {d.y = d.depth * 235}); //d.y dictates how much tree unfolds in x axis distance because it is a horizontal tree, if it was vertical d.y would affect y axis

            // Adding labels for each level
            // using underscore.js library
            var level_labels = ["Jurisdiction", "Component", "Estimation Method", "Parameter", "Data Source"]
            var depthOrder = _.uniq(_.pluck(nodes, "depth")).sort();
            var label_data = [];
            for (var n in depthOrder){
                label_data[n] = {
                    id: parseInt(n),
                    label: level_labels[n]
                };
            }
            
            svg_sticky.selectAll("g.levels-svg").remove();
            var levelSVG = svg_sticky.append("g").attr("class", "levels-svg");
            var levels =  levelSVG.selectAll("g.level");
            levels.data(label_data)
                .enter().append("g")
                .attr("class", "level")
                .attr("transform", function(d) { return "translate(" + d.id*235 + "," + -10 + ")"; })
                .append("text")
                .text(function(d){
                    return d.label;
                })
                // .attr("x", -40)
                .attr("x", function(d) {
                    return d.label === "Estimation Method" ? 40 : 65;})
                .attr("y", 0)
                .attr("font-family","arial")
                .style("font-weight", "bold")
                .style("fill", "#777777")
                //  .transition().duration(duration)
                //  .attr("fill-opacity", 1)

            // NODES *********************************************
            // updating nodes
            var node = svg.selectAll('g.node')
                .data(nodes, d => {return d.id || (d.id = ++i); }) //assigning them a unique id

            // Enter any new nodes at the parent's previous position
            var nodeEnter = node.enter().append('g')
                .attr('class', 'node')
                .attr('transform', d => { return "translate(" + source.y0 + "," + source.x0 + ")"});
                //defined function 'click' below
            
            // add circle for the nodes
            nodeEnter.append('circle')
                .attr('class', 'node')
                .on('click', click)
                .attr('r', 0) // before merging
                .style("fill", "#E55E69" );
                //.style("fill", d => {return d._children ? "blue" : "#fff";}) //before merging

            // ADD LABELS FOR THE NODES
            nodeEnter.append("a")
                .attr("xlink:href", d => {return d.data.uri;})
                .attr("target", "_blank")
            .append('text')
                .attr("dy", "0.35em")
                .attr("x", function(d) {
                    return d.children || d._children ? -13 : 13;})
                //.attr("y", -4) 
                .attr("text-anchor", function(d) {
                    return d.children || d._children ? "end" : "start";
                })
                .text(function(d) { return d.data.name; })
                .call(wrap, 250)  // wrap text labels to 2 lines
                .attr("font-size", "11")
                .style('fill-opacity', 1e-6)
                .style("font-family", "arial")
                .style("fill", "#777777")
                .style("font-weight", "bold")
                .style("text-shadow", "-1px -1px 3px white, -1px 1px 3px white, 1px -1px 3px white, 1px 1px 3px white")
                .style("word-break", "normal")
                
                //.style("pointer-events","all")
                
                
            
            
            

            // UPDATE
            var nodeUpdate = nodeEnter.merge(node); //merge all the elements you "entered"


            // Transition to the proper position for the node
            nodeUpdate.transition()
                .duration(duration)
                .attr("transform", d => {return "translate(" + d.y + "," + d.x + ")";})
                

            // Update node attributes and style
            nodeUpdate.select('circle') // before it said "circle.node"
                .style("fill", "#E55E69")
                //.style("fill", d => {return d._children ? "red" : "blue";})
                .attr('cursor', d => { return d.children || d._children ? 'pointer' : 'default';}) 
                .on("mouseover", function(d) {
                    if (d._children) {
                        d3.select(event.currentTarget).style("fill", "#35BFBA");
                        d3.select(event.currentTarget).attr("r", "11"); 
                    }
                    })
                .on("mouseout", d => {d3.select(event.currentTarget)
                    .style("fill", "#E55E69")
                    .attr("r", "6.5");
                })
                .transition()
                .duration(duration)
                .attr('r', "6.5");

            // Update label/text attributes (transition)
            nodeUpdate.select('text')
                .transition()
                .duration(duration)
                .style('fill-opacity', 1);
                
            // Remove any exiting nodes
            var nodeExit = node.exit().transition()
                .duration(duration)
                .attr("transform", function(d) {
                    return "translate(" + source.y + "," + source.x + ")";
                })
                .remove();

            // On exit reduce the node circles size to 0
            nodeExit.select('circle')
                .attr('r', 1e-6); 

            // On exit reduce the opacity of text labels
            nodeExit.select('text')
                .style('fill-opacity', 1e-6); 


            //LINKS***************************************

            // Update the links...
            var link = svg.selectAll('path.link')
                .data(links, function(d) { return d.id; });

            // Enter any new links at the parent's previous position.
            var linkEnter = link.enter().insert('path', "g")
                .attr("class", "link")
                .attr('d', function(d){
                    var o = {x: source.x0, y: source.y0}
                    return diagonal(o, o)
                });

            // UPDATE
            var linkUpdate = linkEnter.merge(link);

            // Transition back to the parent element position
            linkUpdate.transition()
                .duration(duration)
                .attr('d', function(d){ return diagonal(d, d.parent) })
                .attr("fill", "none")   // without this its gonna fill all black
                .attr("stroke", "#ccc"); // for the black line connecting nodes

            // Remove any exiting links
            var linkExit = link.exit().transition()
                .duration(duration)
                .attr('d', function(d) {
                    var o = {x: source.x, y: source.y}
                    return diagonal(o, o)
                })
                .remove();

            // Store the old positions for transition.
            nodes.forEach(function(d){
                d.x0 = d.x;
                d.y0 = d.y;
            });

            // Creates a curved (diagonal) path from parent to the child nodes
            function diagonal(s, d) {
        /*
                path = `M ${s.y} ${s.x}
                        C ${(s.y + d.y) / 2} ${s.x},
                        ${(s.y + d.y) / 2} ${d.x},
                        ${d.y} ${d.x}`
        */                  path = "M" + s.y + "," + s.x
                        + "C" + (d.y + 20) + "," + s.x
                        + " " + (d.y + 10) + "," + d.x
                        + " " + d.y + "," + d.x;
                return path
            }

            // Toggle children on click.
            function click(d) {
                if (d.children) {
                    d._children = d.children;
                    d.children = null;
                } else {
                    d.children = d._children;
                    d._children = null;
                }
                update(d);
                }
            
            function wrap(text, width) {
                text.each(function() {
                    var text = d3.select(this),
                    words = text.text().split(/\s+/).reverse(),
                    word,
                    line = [],
                    lineNumber = 0,
                    lineHeight = 1, // ems
                    x = text.attr("x"),
                    y = text.attr("y"),
                    dy = parseFloat(text.attr("dy")),
                    tspan = text.text(null).append("tspan").attr("x", x).attr("y", y).attr("dy", dy + "em"); // removed dy + em for making equal line spaces among nodes and leaf nodes
                    while (word = words.pop()) {
                        line.push(word);
                        tspan.text(line.join(" "));
                        if (tspan.node().getComputedTextLength() > width) {
                            line.pop();
                            tspan.text(line.join(" "));
                            line = [word];
                            tspan = text.append("tspan").attr("x", x).attr("y", y).attr("dy", ++lineNumber * lineHeight + dy + "em").text(word);
                            
                        }
                    }
                });

            
                
            } 

        }

        function autoscroll() {
            d3.select("#state_container")
                .transition()
                .duration(1000)
                .tween("scroll", scrollTween((document.body.getBoundingClientRect().height - window.innerHeight)/2 + 150));
            
            function scrollTween(offset) {
                return function() {
                    var i = d3.interpolateNumber(window.pageYOffset || document.documentElement.scrollTop, offset);
                    return function(t) {scrollTo(0, i(t));};
                };
            }
            
        }
    
    })
})


