// d3.json("flare.json").then(function(data) {

// console.log(data)

// tree = d3.cluster()
//     .size([2 * Math.PI, radius - 100])

// colorin = "#00f"
// colorout = "#f00"
// colornone = "#ccc"
// width = 954;
// radius = width / 2;
// line = d3.lineRadial()
//     .curve(d3.curveBundle.beta(0.85))
//     .radius(d => d.y)
//     .angle(d => d.x)

//   const root = tree(bilink(d3.hierarchy(data)
//       .sort((a, b) => d3.ascending(a.height, b.height) || d3.ascending(a.data.name, b.data.name))));

//   const svg = d3.create("svg")
//       .attr("viewBox", [-width / 2, -width / 2, width, width]);

//   const node = svg.append("g")
//       .attr("font-family", "sans-serif")
//       .attr("font-size", 10)
//     .selectAll("g")
//     .data(root.leaves())
//     .join("g")
//       .attr("transform", d => `rotate(${d.x * 180 / Math.PI - 90}) translate(${d.y},0)`)
//     .append("text")
//       .attr("dy", "0.31em")
//       .attr("x", d => d.x < Math.PI ? 6 : -6)
//       .attr("text-anchor", d => d.x < Math.PI ? "start" : "end")
//       .attr("transform", d => d.x >= Math.PI ? "rotate(180)" : null)
//       .text(d => d.data.name)
//       .each(function(d) { d.text = this; })
//       .on("mouseover", overed)
//       .on("mouseout", outed)
//       .call(text => text.append("title").text(d => `${id(d)}
// ${d.outgoing.length} outgoing
// ${d.incoming.length} incoming`));

//   const link = svg.append("g")
//       .attr("stroke", colornone)
//       .attr("fill", "none")
//     .selectAll("path")
//     .data(root.leaves().flatMap(leaf => leaf.outgoing))
//     .join("path")
//       .style("mix-blend-mode", "multiply")
//       .attr("d", ([i, o]) => line(i.path(o)))
//       .each(function(d) { d.path = this; });

//   function overed(d) {
//     link.style("mix-blend-mode", null);
//     d3.select(this).attr("font-weight", "bold");
//     d3.selectAll(d.incoming.map(d => d.path)).attr("stroke", colorin).raise();
//     d3.selectAll(d.incoming.map(([d]) => d.text)).attr("fill", colorin).attr("font-weight", "bold");
//     d3.selectAll(d.outgoing.map(d => d.path)).attr("stroke", colorout).raise();
//     d3.selectAll(d.outgoing.map(([, d]) => d.text)).attr("fill", colorout).attr("font-weight", "bold");
//   }

//   function outed(d) {
//     link.style("mix-blend-mode", "multiply");
//     d3.select(this).attr("font-weight", null);
//     d3.selectAll(d.incoming.map(d => d.path)).attr("stroke", null);
//     d3.selectAll(d.incoming.map(([d]) => d.text)).attr("fill", null).attr("font-weight", null);
//     d3.selectAll(d.outgoing.map(d => d.path)).attr("stroke", null);
//     d3.selectAll(d.outgoing.map(([, d]) => d.text)).attr("fill", null).attr("font-weight", null);
//   }

//   return svg.node();

//   function hierarchy(data, delimiter = ".") {
//     let root;
//     const map = new Map;
//     data.forEach(function find(data) {
//       const {name} = data;
//       if (map.has(name)) return map.get(name);
//       const i = name.lastIndexOf(delimiter);
//       map.set(name, data);
//       if (i >= 0) {
//         find({name: name.substring(0, i), children: []}).children.push(data);
//         data.name = name.substring(i + 1);
//       } else {
//         root = data;
//       }
//       return data;
//     });
//     return root;
//   }

//   function bilink(root) {
//     const map = new Map(root.leaves().map(d => [id(d), d]));
//     for (const d of root.leaves()) d.incoming = [], d.outgoing = d.data.imports.map(i => [d, map.get(i)]);
//     for (const d of root.leaves()) for (const o of d.outgoing) o[1].incoming.push(o);
//     return root;
//   }

//   function id(node) {
//     return `${node.parent ? id(node.parent) + "." : ""}${node.data.name}`;
//   }

// })







// data = hierarchy(await FileAttachment("flare.json").json())

//     console.log(data)
//     let colorin = "#00f"
//     let colorout = "#f00"

//     let colornone = "#ccc"

//     let width = 1200
//     let height = 1200
//     let radius = width / 2


//     const tree = d3.cluster()
//         .size([2 * Math.PI, radius - 100])

//     const root = tree(bilink(d3.hierarchy(data)
//         .sort((a, b) => d3.ascending(a.height, b.height) || d3.ascending(a.data.name, b.data.name))));


//     const line = d3.lineRadial()
//         .curve(d3.curveBundle.beta(0.85))
//         .radius(d => d.y)
//         .angle(d => d.x)

    
//     const svg = d3.select("svg")
//         .attr("width", width)
//     .attr("height",height)
//     .attr("viewBox", [-width / 2, -width / 2, width, width]);
//     g = svg.append("g").attr("transform", "translate(" + (width / 2 + 110) + "," + (height / 2 + 110) + ")"); 


//     const node = svg.append("g")
//         .attr("font-family", "sans-serif")
//         .attr("font-size", 10)
//         .selectAll("g")
//         .data(root.leaves())
//         .join("g")
//         .attr("transform", d => `rotate(${d.x * 180 / Math.PI - 90}) translate(${d.y},0)`)
//         .append("text")
//         .attr("dy", "0.31em")
//         .attr("x", d => d.x < Math.PI ? 6 : -6)
//         .attr("text-anchor", d => d.x < Math.PI ? "start" : "end")
//         .attr("transform", d => d.x >= Math.PI ? "rotate(180)" : null)
//         .text(d => d.data.name)
//         .each(function(d) { d.text = this; })
//         .on("mouseover", overed)
//         .on("mouseout", outed)
//         .call(text => text.append("title").text(d => `${id(d)}
//             ${d.outgoing.length} outgoing
//             ${d.incoming.length} incoming`))
//             console.log("node", node);

//     const link = svg.append("g")
//         .attr("stroke", colornone)
//         .attr("fill", "none")
//         .selectAll("path")
//         .data(root.leaves().flatMap(leaf => leaf.outgoing))
//         .join("path")
//         .style("mix-blend-mode", "multiply")
//         .attr("d", ([i, o]) => line(i.path(o)))
//         .each(function(d) { d.path = this; })
//         console.log("node", link);
        
//     console.log("svg", svg);

//     function overed(d) {
//         link.style("mix-blend-mode", null);
//         d3.select(this).attr("font-weight", "bold");
//         d3.selectAll(d.incoming.map(d => d.path)).attr("stroke", colorin).raise();
//         d3.selectAll(d.incoming.map(([d]) => d.text)).attr("fill", colorin).attr("font-weight", "bold");
//         d3.selectAll(d.outgoing.map(d => d.path)).attr("stroke", colorout).raise();
//         d3.selectAll(d.outgoing.map(([, d]) => d.text)).attr("fill", colorout).attr("font-weight", "bold");
//     }

//     function outed(d) {
//         link.style("mix-blend-mode", "multiply");
//         d3.select(this).attr("font-weight", null);
//         d3.selectAll(d.incoming.map(d => d.path)).attr("stroke", null);
//         d3.selectAll(d.incoming.map(([d]) => d.text)).attr("fill", null).attr("font-weight", null);
//         d3.selectAll(d.outgoing.map(d => d.path)).attr("stroke", null);
//         d3.selectAll(d.outgoing.map(([, d]) => d.text)).attr("fill", null).attr("font-weight", null);
//     }


//     function hierarchy(data, delimiter = ".") {
//         let root;
//         const map = new Map;
//         data.forEach(function find(data) {
//           const {name} = data;
//           if (map.has(name)) return map.get(name);
//           const i = name.lastIndexOf(delimiter);
//           map.set(name, data);
//           if (i >= 0) {
//             find({name: name.substring(0, i), children: []}).children.push(data);
//             data.name = name.substring(i + 1);
//           } else {
//             root = data;
//           }
//           return data;
//         });
//         return root;
//       }
    
    
    

//     function bilink(root) {
//         const map = new Map(root.leaves().map(d => [id(d), d]));
//              for (const d of root.leaves()) d.incoming = [], d.outgoing = d.data.imports.map(i => [d, map.get(i)]);
//              for (const d of root.leaves()) for (const o of d.outgoing) o[1].incoming.push(o);
//         return root;
//     }

//     function id(node) {
//     return `${node.parent ? id(node.parent) + "." : ""}${node.data.name}`;
//     }






var diameter = 960,
    radius = diameter / 2,
    innerRadius = radius - 120;

var cluster = d3.cluster()
    .size([360, innerRadius]);

var line = d3.radialLine()
    .curve(d3.curveBundle.beta(0.85))
    .radius(function(d) { return d.y; })
    .angle(function(d) { return d.x / 180 * Math.PI; });

var svg = d3.select("body").append("svg")
    .attr("width", diameter)
    .attr("height", diameter)
  .append("g")
    .attr("transform", "translate(" + radius + "," + radius + ")");

var link = svg.append("g").selectAll(".link"),
    node = svg.append("g").selectAll(".node");

d3.json("flare.json", function(error, classes) {
  if (error) throw error;

  var root = packageHierarchy(classes)
      .sum(function(d) { return d.size; });

  cluster(root);

  link = link
    .data(packageImports(root.leaves()))
    .enter().append("path")
      .each(function(d) { d.source = d[0], d.target = d[d.length - 1]; })
      .attr("class", "link")
      .attr("d", line);

  node = node
    .data(root.leaves())
    .enter().append("text")
      .attr("class", "node")
      .attr("dy", "0.31em")
      .attr("transform", function(d) { return "rotate(" + (d.x - 90) + ")translate(" + (d.y + 8) + ",0)" + (d.x < 180 ? "" : "rotate(180)"); })
      .attr("text-anchor", function(d) { return d.x < 180 ? "start" : "end"; })
      .text(function(d) { return d.data.key; })
      .on("mouseover", mouseovered)
      .on("mouseout", mouseouted);
});

function mouseovered(d) {
  node
      .each(function(n) { n.target = n.source = false; });

  link
      .classed("link--target", function(l) { if (l.target === d) return l.source.source = true; })
      .classed("link--source", function(l) { if (l.source === d) return l.target.target = true; })
    .filter(function(l) { return l.target === d || l.source === d; })
      .raise();

  node
      .classed("node--target", function(n) { return n.target; })
      .classed("node--source", function(n) { return n.source; });
}

function mouseouted(d) {
  link
      .classed("link--target", false)
      .classed("link--source", false);

  node
      .classed("node--target", false)
      .classed("node--source", false);
}

// Lazily construct the package hierarchy from class names.
function packageHierarchy(classes) {
  var map = {};

  function find(name, data) {
    var node = map[name], i;
    if (!node) {
      node = map[name] = data || {name: name, children: []};
      if (name.length) {
        node.parent = find(name.substring(0, i = name.lastIndexOf(".")));
        node.parent.children.push(node);
        node.key = name.substring(i + 1);
      }
    }
    return node;
  }

  classes.forEach(function(d) {
    find(d.name, d);
  });

  return d3.hierarchy(map[""]);
}

// Return a list of imports for the given array of nodes.
function packageImports(nodes) {
  var map = {},
      imports = [];

  // Compute a map from name to node.
  nodes.forEach(function(d) {
    map[d.data.name] = d;
  });

  // For each import, construct a link from the source to target node.
  nodes.forEach(function(d) {
    if (d.data.imports) d.data.imports.forEach(function(i) {
      imports.push(map[d.data.name].path(map[i]));
    });
  });

  return imports;
}
