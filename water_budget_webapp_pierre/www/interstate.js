Shiny.addCustomMessageHandler("interstate_choice",
function (message) {

    // input selected by user
    var interstate_choice = message;
    //var printABC = function () {return "this is function";}

    // loading csv file based on input choice for interstate relationship
    if (interstate_choice == "Exact Match"){
      var csv_data =  "df_exact_match.csv";
    } else if (interstate_choice == "Subcomponent"){
      csv_data = "df_subcomponent.json";

      d3.selectAll("svg").remove();

      d3.json("df_subcomponent.json").then(function(abc) {


        console.log(abc)
     //convert typeof import to array
     abc.forEach(item =>{
       item["imports"] = item["imports"].split(',')
       // change objects that have "" to empty 
       //console.log(Object.values(item.imports))
       if (Object.values(item.imports)[0] == "") {
         item.imports.length = 0;
       }
     })
     
       data = hierarchy(abc)
     
       //console.log(data)
         // //convert typeof import to array
         // data.forEach(item =>{
         //   item["imports"] = item["imports"].split(',')
         // })
     
       var diameter = 960,
       radius = diameter / 2,
     
       colorin = "#E55E69";
       colorout = "#00AFA8";
       colornone = "#bbb";
     
       width = 954;
       radius = width/2;
     
       line = d3.lineRadial()
         .curve(d3.curveBundle.beta(0.85))
         .radius(d => d.y)
         .angle(d => d.x)
     
       tree = d3.cluster()
         .size([2 * Math.PI, radius - 100])
     
       const root = tree(bilink(d3.hierarchy(data)
           .sort((a, b) => d3.ascending(a.height, b.height) || d3.ascending(a.data.name, b.data.name))));
     
       // const svg = d3.create("svg")
       //     .attr("viewBox", [-width / 2, -width / 2, width, width]);
     
       var svg = d3.select("#interstate_container").append("svg")
         .attr("width", diameter + 800)
         .attr("height", diameter + 500)
       .append("g")
         .attr("transform", "translate(" + (radius + 400) + "," + (radius + 200) + ")");
     
     var link = svg.append("g").selectAll(".link")
     var node = svg.append("g").selectAll(".node");
     
       node = svg.append("g")
           .attr("font-family", "sans-serif")
           .attr("font-size", 10)
         .selectAll("g")
         .data(root.leaves())
         .join("g")
           .attr("transform", d => `rotate(${d.x * 180 / Math.PI - 90}) translate(${d.y},0)`)
         .append("text")
           .attr("dy", "0.31em")
           .attr("x", d => d.x < Math.PI ? 6 : -6)
           .attr("text-anchor", d => d.x < Math.PI ? "start" : "end")
           .attr("transform", d => d.x >= Math.PI ? "rotate(180)" : null)
           .text(d => d.data.name)
           .each(function(d) { d.text = this; })
           .attr("fill", colornone)  // default text color
           .attr("font-weight", "bold")                     
           .on("mouseover", overed)
           .on("mouseout", outed)
           .attr('cursor', 'pointer')
           .style("font-family", "arial")
           .attr("font-size", "11")
           .call(text => text.append("title").text(d => `${id(d)}
     b. Has ${d.outgoing.length} subcomponents (in green)
     c. Is subcomponent of ${d.incoming.length} (in red)`));
     
       link = svg.append("g")
           .attr("stroke", "lightgray")
           .attr("fill", "none")
         .selectAll("path")
         .data(root.leaves().flatMap(leaf => leaf.outgoing))
         .join("path")
           .style("mix-blend-mode", "multiply") //what to do if multiple path lines overlaps
           .attr("d", ([i, o]) => line(i.path(o)))
           .each(function(d) { d.path = this; });
     
       function overed(d) {
         link.style("mix-blend-mode", null); //remove multiply effect when hovering a node
         d3.select(this).attr("font-weight", "bold");
         d3.select(this).attr("fill", "#777777"); //on hover in, it darkens selected node
     
         d3.selectAll(d.incoming.map(d => d.path)).attr("stroke", colorin).raise();
         d3.selectAll(d.incoming.map(([d]) => d.text)).attr("fill", colorin).attr("font-weight", "bold");
         d3.selectAll(d.outgoing.map(d => d.path)).attr("stroke", colorout).raise();
         d3.selectAll(d.outgoing.map(([, d]) => d.text)).attr("fill", colorout).attr("font-weight", "bold");
       }
     
       function outed(d) { // set colornone to restore default gray text color after hover out
         link.style("mix-blend-mode", "multiply");
         d3.select(this).attr("font-weight", "bold");
         d3.select(this).attr("fill", colornone); //on hover out, restores text color of selected node
     
         d3.selectAll(d.incoming.map(d => d.path)).attr("stroke", "lightgray");
         d3.selectAll(d.incoming.map(([d]) => d.text)).attr("fill", colornone).attr("font-weight", "bold");
         d3.selectAll(d.outgoing.map(d => d.path)).attr("stroke", "lightgray");
         d3.selectAll(d.outgoing.map(([, d]) => d.text)).attr("fill", colornone).attr("font-weight", "bold");
       }
     
       //return svg.node();
     
       function hierarchy(data, delimiter = ".") {
         let root;
         const map = new Map;
         data.forEach(function find(data) {
           const {name} = data;
           if (map.has(name)) return map.get(name);
           const i = name.lastIndexOf(delimiter);
           map.set(name, data);
           if (i >= 0) {
             find({name: name.substring(0, i), children: []}).children.push(data);
             data.name = name.substring(i + 1);
           } else {
             root = data;
           }
           return data;
         });
         return root;
       }
     
       function bilink(root) {
         const map = new Map(root.leaves().map(d => [id(d), d]));
         for (const d of root.leaves()) d.incoming = [], d.outgoing = d.data.imports.map(i => [d, map.get(i)]);
         for (const d of root.leaves()) for (const o of d.outgoing) o[1].incoming.push(o);
         return root;
       }
     
       function id(node) {
         return `${node.parent ? id(node.parent) + "." : ""}${node.data.name}`;
       }
     
     });











    } else if (interstate_choice == "Partial Subcomponent"){
      csv_data = "df_partial_subcomponent.csv";


          // d3 begins...

    d3.csv(csv_data).then(function (data) {

      d3.selectAll("svg").remove();

      //convert typeof import to array
      data.forEach(item => {
        item["imports"] = item["imports"].split(',')
      })

      var diameter = 960,
        radius = diameter / 2,
        innerRadius = radius - 250;

      var cluster = d3.cluster()
        .size([360, innerRadius]);

      // Lines linking nodes
      var line = d3.lineRadial()   //changed radial line to line radial 
        .curve(d3.curveBundle.beta(0.85)) //amount of curve, change beta to see
        .radius(function (d) { return d.y; }) //when should the lines end, if you add a value to d.y the lines will become longer
        .angle(function (d) { return d.x / 180 * Math.PI; });

      var svg = d3.select("#interstate_container").append("svg")
        .attr("width", diameter + 400)
        .attr("height", diameter + 400)
        .append("g")
        .attr("transform", "translate(" + (radius + 200) + "," + (radius + 100) + ")");

      // Background rectangle
      svg.append("rect")
      .attr("width", diameter + 200)
      .attr("height", diameter + 300)
      .attr("transform", "translate(" + -(radius + 100)  + "," + -(radius + 100) + ")")
      .attr("fill", "#F8F8F8")
      .attr('rx', 20);
      
      var i = 0;

      // Auto-scroll
      var scrollCount = 1;
      while (scrollCount < 2) {
          autoscroll();
          scrollCount++ ;
      }

      var link = svg.append("g").selectAll(".link")
      var node = svg.append("g").selectAll(".node");

      // d3.json("flare.json", function(error, data) {
      //   if (error) throw error;

      var root = packageHierarchy(data)
        .sum(function (d) { return d.size; });

      cluster(root);

      link = link
        .data(packageImports(root.leaves()))
        .enter().append("path")
        .each(function (d) { d.source = d[0], d.target = d[d.length - 1]; })
        .attr("class", "link_interstate")
        .attr("d", line)
      //  .style("stroke", "cyan");

      node = node
        .data(root.leaves())
        .enter().append("text")
        .attr("class", "node_interstate")
        .attr("dy", "0.31em")
        .attr("transform", function (d) { return "rotate(" + (d.x - 90) + ")translate(" + (d.y + 8) + ",0)" + (d.x < 180 ? "" : "rotate(180)"); })
        .attr("text-anchor", function (d) { return d.x < 180 ? "start" : "end"; })
        .text(function (d) { return d.data.key; })
        .on("mouseover", mouseovered)
        .on("mouseout", mouseouted)
        .attr('cursor', 'pointer')
        //.style("font-weight", 1000)
        //.style("font-size", 1)
        //.style("font-family", "arial")
        // .style("fill", "#bbb")
        // .on("mouseover", d => {d3.select(event.currentTarget)
        //   .style("fill", "#000")
        //   .style("font-weight", 700);})
        // .on("mouseout", d => {d3.select(event.currentTarget)
        //   .style("fill", "#bbb")
        //   .style("font-weight", 300);})
        ;
      // });     


      function mouseovered(d) {
        node
          .each(function (n) { n.target = n.source = false; });

        link
          .classed("link--target", function (l) { if (l.target === d) return l.source.source = true; })
          .classed("link--source", function (l) { if (l.source === d) return l.target.target = true; })
          .filter(function (l) { return l.target === d || l.source === d; })
          .raise();

        node
          .classed("node--target", function (n) { return n.target; })
          .classed("node--source", function (n) { return n.source; });
      }

      function mouseouted(d) {
        link
          .classed("link--target", false)
          .classed("link--source", false);

        node
          .classed("node--target", false)
          .classed("node--source", false);
      }

      // Lazily construct the package hierarchy from class names (changed "classes" to "data").
      function packageHierarchy(data) {
        var map = {};

        function find(name, data) {
          var node = map[name], i;
          if (!node) {
            node = map[name] = data || { name: name, children: [] };
            if (name.length) {
              node.parent = find(name.substring(0, i = name.lastIndexOf(".")));
              node.parent.children.push(node);
              node.key = name.substring(i + 1);
            }
          }
          return node;
        }

        data.forEach(function (d) {
          find(d.name, d);
        });

        return d3.hierarchy(map[""]);
      }

      // Return a list of imports for the given array of nodes.
      function packageImports(nodes) {
        var map = {},
          imports = [];

        // Compute a map from name to node.
        nodes.forEach(function (d) {
          map[d.data.name] = d;
        });

        // For each import, construct a link from the source to target node.
        nodes.forEach(function (d) {
          if (d.data.imports) d.data.imports.forEach(function (i) {
            imports.push(map[d.data.name].path(map[i]));
          });
        });

        return imports;
      }

      function autoscroll() {
        d3.select("#interstate_container")
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





    }


  })
    
