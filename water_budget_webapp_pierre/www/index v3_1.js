// var hyp_data = [];

// function preparingUrl () {
//         // Loading and parsing csv containing hyperlinks
//     // var index = [];
//     // var j = [];
//     // var jL = [];
//     // var c = [];
//     // var cL = [];
//     // var em = [];
//     // var emL = [];
//     // var p = [];
//     // var pL = [];
//     // var ds = [];
//     // var dsL = [];


//     getData(); //we make function because async only works with functions
//     async function getData() {
//     const response = await fetch('hyperlink.csv');
//     const response_data = await response.text();
    
//     const table = response_data.split("\r\n").slice(1);
//     //    const col_header = ["index","j","jL","c","cL","em","emL","p","pL","ds","dsL"];

//     table.forEach(row=> {
//             const col = row.split(",");
//             // const index = col[0];
//             // const J = col[1];
//             // j.push(J);
//             // const JL = col[2];
//             // jL.push(JL);
//             // const C = col[3];
//             // c.push(C);
//             // const CL = col[4];
//             // cL.push(CL);
//             // const EM = col[5];
//             // em.push(EM);
//             // const EML = col[6];
//             // emL.push(EML);
//             // const P = col[7];
//             // p.push(P);
//             // const PL = col[8];
//             // pL.push(PL);
//             // const DS = col[9];
//             // ds.push(DS);
//             // const DSL = col[10];
//             // dsL.push(DSL);
//             hyp_data.push(col);
//         })
//         console.log(hyp_data[0])
//     }
    
// }



// reading csv file

var hyp_data = [];

d3.csv("hyperlink.csv").then(function(data) {
    hyp_data = data;
    console.log(hyp_data);

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

        //preparingUrl();

        // data.children[0].children.forEach(object =>
        //     console.log(object.name))
        //console.log(hyp_data[0]['c'])
        //console.log(data.children[0].children[0].name + '-' + hyp_data[0]['jL'] )
        
    // indexing not working out of getdata function for hyp_data



            //console.log(obj.s)
        //console.log(dsL)

        // if (cL === data.children.children.name) {
        //     console.log("TRUE")
        // } else {
        //     console.log("FALSE")
        // }

        // Below came out true
        // if (hyp_data[0]['cL'] === data.children[0].children[0].name + '-' + data.children[0].name) {
        //     data.children[0].children[0].url = hyp_data[0]['c']
        // } 

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
            hyp_data.forEach(item => {
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
        
        // // Extract j and jL into j_uri
        // hyp_data.forEach((item) => {
        //     j_uri.push({
        //         'jL': item['jL'],
        //         'j': item['j']
        //     })
        // })

        // // Extract c and cL into c_uri
        // hyp_data.forEach((item) => {
        //     c_uri.push({
        //         'cL': item['cL'],
        //         'c': item['c']
        //     })
        // })

        // // Extract em and emL into em_uri
        // hyp_data.forEach((item) => {
        //     em_uri.push({
        //         'emL': item['emL'],
        //         'em': item['em']
        //     })
        // })

        // // Extract p and pL into p_uri
        // hyp_data.forEach((item) => {
        //     p_uri.push({
        //         'pL': item['pL'],
        //         'p': item['p']
        //     })
        // })

        // // Extract ds and dsL into ds_uri
        // hyp_data.forEach((item) => {
        //     ds_uri.push({
        //         'dsL': item['dsL'],
        //         'ds': item['ds']
        //     })
        // })

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

        //////// Extract unique j and jL into j_uri_unique
        // const j_map = new Map();
        // for (const item of j_uri) {
        //     if(!j_map.has(item['jL'])){
        //         j_map.set(item['jL'], true);
        //         j_uri_unique.push({
        //             'jL': item['jL'],
        //             'j': item['j']
        //         });
        //     }
        // }
        
        // // Extract unique c and cL into c_uri_unique
        // const c_map = new Map();
        // for (const item of c_uri) {
        //     if(!c_map.has(item['cL'])){
        //         c_map.set(item['cL'], true);
        //         c_uri_unique.push({
        //             'cL': item['cL'],
        //             'c': item['c']
        //         });
        //     }
        // }

        // // Extract unique em and emL into em_uri_unique
        // const em_map = new Map();
        // for (const item of em_uri) {
        //     if(!em_map.has(item['emL'])){
        //         em_map.set(item['emL'], true);
        //         em_uri_unique.push({
        //             'emL': item['emL'],
        //             'em': item['em']
        //         });
        //     }
        // }

        // // Extract unique p and pL into c_uri_unique
        // const p_map = new Map();
        // for (const item of p_uri) {
        //     if(!p_map.has(item['pL'])){
        //         p_map.set(item['pL'], true);
        //         p_uri_unique.push({
        //             'pL': item['pL'],
        //             'p': item['p']
        //         });
        //     }
        // }

        // // Extract unique ds and dsL into c_uri_unique
        // const ds_map = new Map();
        // for (const item of ds_uri) {
        //     if(!ds_map.has(item['dsL'])){
        //         ds_map.set(item['dsL'], true);
        //         ds_uri_unique.push({
        //             'dsL': item['dsL'],
        //             'ds': item['ds']
        //         });
        //     }
        // }


        //console.log(em_uri_unique[5]['emL'])

        //creating url as a property to add to each children node
        function add_uri(array, uri, label, item, index){
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

        //adding url as a property to each children node
        data.children.forEach((item1, index) => {
            add_uri(j_uri_unique, 'j', 'jL', item1);
            item1.children.forEach(item2 => {
                add_uri(c_uri_unique, 'c', 'cL', item2, parseInt(index));
                //console.log(index);
                item2.children.forEach(item3 =>{
                    add_uri(em_uri_unique, 'em', 'emL', item3);
                    item3.children.forEach(item4 => {
                        add_uri(p_uri_unique, 'p', 'pL', item4);
                        item4.children.forEach(item5 => {
                            add_uri(ds_uri_unique, 'ds', 'dsL', item5);
                        })
                    })
                })
            })
        })

        
        // data.children.forEach(item1 => {
        //     for (const j in j_uri_unique){
        //         if (j_uri_unique[j]['jL'] === item1['name']){
        //             //console.log("true");
        //             item1["url"] = j_uri_unique[j]['j'];
        //         } 
        //     }
        //     item1.children.forEach(item2 => {
        //         for (const c in c_uri_unique){
        //             if (c_uri_unique[c]['cL'] === item2['name']+ '-' + data.children[0].name){
        //                 //console.log("true");
        //                 item2["url"] = c_uri_unique[c]['c'];
        //             } 
        //         }
        //         item2.children.forEach(item3 =>{
        //             for (const em in em_uri_unique){
        //                 if (em_uri_unique[em]['emL'] === item3['name']){
        //                     //console.log("true");
        //                     item3["url"] = em_uri_unique[em]['em'];
        //                 } 
        //             }
        //             item3.children.forEach(item4 => {
        //                 for (const p in p_uri_unique){
        //                     if (p_uri_unique[p]['pL'] === item4['name']){
        //                         //console.log("true");
        //                         item4["url"] = p_uri_unique[p]['p'];
        //                     } 
        //                 }
        //                 item4.children.forEach(item5 => {
        //                     for (const ds in ds_uri_unique){
        //                         if (ds_uri_unique[ds]['dsL'] === item5['name']){
        //                             console.log("true");
        //                             item5["url"] = ds_uri_unique[ds]['ds'];
        //                         } 
        //                     }
        //                 })
        //             })
        //         })
        //     })
        // })

        
    












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