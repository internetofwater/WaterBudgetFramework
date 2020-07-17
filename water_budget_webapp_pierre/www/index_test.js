///////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////this is copied from index v3_1.js and removing unused code to add uri/////////////////////////////////
/////////////////////////this will be used to test features before implementing in latest index version/////////////////////////////////////

// reading csv file

var uri_data = [];

d3.csv("hyperlink.csv").then(function(data) {
    uri_data = data;
    console.log(uri_data);

    d3.json("sample_json_v2.json")
    .then(loadData)

    //setting dimensions and margins for graph
    //var width = 1000;
    //var height = 1000;
    var margin = {top: 20, right: 90, bottom: 30, left: 90}
    var width = 1500 - margin.left - margin.right //change width because leaf nodes were going out
    var height = 1200 - margin.top - margin.bottom; //1200 height for about 40 leaf nodes

    // appending svg object to the body div "container"
    var svg = d3.select("#container")
        .append("svg")
            .attr("width", width + margin.right + margin.left)
            .attr("height", height + margin.top + margin.bottom)
        .append("g")
            .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

    var i = 0
    var duration = 750
    var root;

    function loadData(data) {

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

        ///////Function to store each level elements in an array
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
        

        var j_map, c_map, em_map, p_map, ds_map;

        // function to extract unique values from previous arrays
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

        //creating a function to add uri as a property to add to each children node
        function addURI(array, uri, label, item, index){
            if (uri === 'c'){
                for (const level_name in array){
                    if (array[level_name][label] === item["name"] + '-' + data.children[index].name) {
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
        data.children.forEach((item1, index) => {
            addURI(j_uri_unique, 'j', 'jL', item1);
            item1.children.forEach(item2 => {
                addURI(c_uri_unique, 'c', 'cL', item2, parseInt(index));
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
        })

//////////////////////////////////////D3 Chart//////////////////////////////////
        
        console.log(data)

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
            var depthOrder = _.uniq(_.pluck(nodes, "depth")).sort();
            svg.selectAll("g.levels-svg").remove();
            var levelSVG = svg.append("g").attr("class", "levels-svg");
            var levels =  levelSVG.selectAll("g.level");
            levels.data(depthOrder)
                .enter().append("g")
                .attr("class", "level")
                .attr("transform", function(d) { return "translate(" + d*235 + "," + 10 + ")"; })
                .append("text")
                .text(function(d){
                        return data.colname;
                })
                .attr("x", -10)
                .attr("font-family","arial")
                .style("font-weight", "bold")
                .style("fill", "#777777");
                

            // NODES *********************************************
            // updating nodes
            var node = svg.selectAll('g.node')
                .data(nodes, d => {return d.id || (d.id = ++i); }) //assigning them a unique id

            // Enter any new nodes at the parent's previous position
            var nodeEnter = node.enter().append('g')
                .attr('class', 'node')
                .attr('transform', d => { return "translate(" + source.y0 + "," + source.x0 + ")"});
                //defined this function below
            
            // add circle for the nodes
            nodeEnter.append('circle')
                .attr('class', 'node')
                .attr('r', 0) // before merging
                .style("fill", "#E55E69" )
                .on('click', click);
                //.style("fill", d => {return d._children ? "blue" : "#fff";}) //before merging

            // ADD LABELS FOR THE NODES
            nodeEnter.append('text')
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
                .style("word-break", "normal");

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
                        d3.select(event.currentTarget).attr("r", "12"); 
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
                }
                else {
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
        
    }

})