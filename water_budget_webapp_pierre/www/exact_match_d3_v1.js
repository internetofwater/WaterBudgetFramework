const abc = [
  {"name": "a.A", "imports": ["a.B", "a.C", "a.D"]},
  {"name": "a.B", "imports": ["a.C", "a.D"]},
  {"name": "a.C", "imports": ["a.D"]},
  {"name": "a.D", "imports": []},
  {"name": "a.E", "imports": ["a.A"]}
 ]



//d3.json("df_exact_match_v2.json").then(function(abc) {


   console.log(abc)

// //convert typeof import to array
// abc.forEach(item =>{
//   item["imports"] = item["imports"].split(',')
//   // change objects that have "" to empty 
//   //console.log(Object.values(item.imports))
//   if (Object.values(item.imports)[0] == "") {
//     item.imports.length = 0;
//   }
// }) 

  data = hierarchy(abc)

  //console.log(data)
    // //convert typeof import to array
    // data.forEach(item =>{
    //   item["imports"] = item["imports"].split(',')
    // })

  var diameter = 500,
  radius = diameter / 2,

  colorin = "#E55E69";
  colorout = "#00AFA8";
  colornone = "#bbb";

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

  var svg = d3.select("body").append("svg")
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

//});