# Using edge bundle
library (edgebundleR)
library(rvest)
library(dplyr)
library(xtable)
library(stringr)
library(data.table)

#import round d3
component <- read_csv("./www/round_d3.csv")

#rename columns
colnames(component)[1] <- "from"
colnames(component)[2] <- "to"
component <- as.data.frame(component)

# nodes
nodes <- c(component$from, component$to)
nodes <- as.data.frame(nodes)
nodes_unique <- unique(nodes)

#rearrange rows
d <- data.frame(do.call('rbind', str_split(nodes_unique$nodes, "-")))

for (i in 1: nrow(d)){
  d$combined[i] <- paste0(d[i,1], "-", d[i,2])
}

col_order <- c("combined","X2","X1")
d <- d[,col_order]
d <- arrange(d, X2, combined)

  
# we need components and nodes dataframe to work in in edgebundlR

#igraph_obj <- graph_from_data_frame(component)

g <- graph.data.frame(component, directed=F, vertices=d)

clr <- as.factor(V(g)$X2)
levels(clr) <- c("salmon", "wheat", "lightskyblue", "cyan")
V(g)$color <- as.character(clr)
V(g)$size = degree(g)*5

edgebundle(g)

# why "duplicate vertex names"
# stack overflow answer

# myvertices <- read.csv(stringsAsFactors=F, text="
# id,name,feature_a,feature_b,feature_c
# a,foo,1,2,3
# b,bar,1,2,3
# c,extra,1,2,3")
# 
# myedges <- read.csv(stringsAsFactors=F, text="
# id,from,to,feature_d,feature_e,feature_f
# 1,a,b,1,2,3")
# 
# graph.data.frame(myedges[, -1], directed=TRUE, vertices=myvertices)
# # IGRAPH DN-- 3 1 -- 
# # + attr: name (v/c), feature_a (v/n), feature_b (v/n), feature_c (v/n), feature_d (e/n), feature_e (e/n), feature_f (e/n)
# # + edge (vertex names):
# # [1] foo->bar
# 
# myvertices$id[3] <- "a" # duplicate a
# graph.data.frame(myedges[, -1], directed=TRUE, vertices=myvertices)
# Error in graph.data.frame(myedges[, -1], directed = TRUE, vertices = myvertices) : 
#   Duplicate vertex names


#############################################
#edgebundle example 1

d <- structure(list(ID = c("KP1009", "GP3040", "KP1757", "GP2243",
                           "KP682", "KP1789", "KP1933", "KP1662", "KP1718", "GP3339", "GP4007",
                           "GP3398", "GP6720", "KP808", "KP1154", "KP748", "GP4263", "GP1132",
                           "GP5881", "GP6291", "KP1004", "KP1998", "GP4123", "GP5930", "KP1070",
                           "KP905", "KP579", "KP1100", "KP587", "GP913", "GP4864", "KP1513",
                           "GP5979", "KP730", "KP1412", "KP615", "KP1315", "KP993", "GP1521",
                           "KP1034", "KP651", "GP2876", "GP4715", "GP5056", "GP555", "GP408",
                           "GP4217", "GP641"),
                    Type = c("B", "A", "B", "A", "B", "B", "B",
                             "B", "B", "A", "A", "A", "A", "B", "B", "B", "A", "A", "A", "A",
                             "B", "B", "A", "A", "B", "B", "B", "B", "B", "A", "A", "B", "A",
                             "B", "B", "B", "B", "B", "A", "B", "B", "A", "A", "A", "A", "A",
                             "A", "A"),
                    Set = c(15L, 1L, 10L, 21L, 5L, 9L, 12L, 15L, 16L,
                            19L, 22L, 3L, 12L, 22L, 15L, 25L, 10L, 25L, 12L, 3L, 10L, 8L,
                            8L, 20L, 20L, 19L, 25L, 15L, 6L, 21L, 9L, 5L, 24L, 9L, 20L, 5L,
                            2L, 2L, 11L, 9L, 16L, 10L, 21L, 4L, 1L, 8L, 5L, 11L),
                    Loc = c(3L, 2L, 3L, 1L, 3L, 3L, 3L, 1L, 2L,
                            1L, 3L, 1L, 1L, 2L, 2L, 1L, 3L,
                            2L, 2L, 2L, 3L, 2L, 3L, 2L, 1L, 3L, 3L, 3L, 2L, 3L, 1L, 3L, 3L,
                            1L, 3L, 2L, 3L, 1L, 1L, 1L, 2L, 3L, 3L, 3L, 2L, 2L, 3L, 3L)),
               .Names = c("ID", "Type", "Set", "Loc"), class = "data.frame",
               row.names = c(NA, -48L))
# let's add Loc to our ID
d$key <- d$ID
d$ID <- paste0(d$Loc,".",d$ID)
# Get vertex relationships
sets <- unique(d$Set[duplicated(d$Set)]) # only take unique values of values that are duplicated
rel <-  vector("list", length(sets)) # making vector of list
for (i in 1:length(sets)) {
  rel[[i]] <- as.data.frame(t(combn(subset(d, d$Set ==sets[i])$ID, 2)))
}
rel <- rbindlist(rel)
# Get the graph
g <- graph.data.frame(rel, directed=F, vertices=d)
clr <- as.factor(V(g)$Loc)
levels(clr) <- c("salmon", "wheat", "lightskyblue")
V(g)$color <- as.character(clr)
V(g)$size = degree(g)*5
# igraph static plot
# plot(g, layout = layout.circle, vertex.label=NA)

edgebundle( g )


#############################################
#edgebundle example 2

require(MASS)
sig = kronecker(diag(3),matrix(2,5,5)) + 3*diag(15)
X = MASS::mvrnorm(n=100,mu=rep(0,15),Sigma = sig)
colnames(X) = paste(rep(c("A.A","B.B","C.C"),each=5),1:5,sep="")
edgebundle(cor(X),cutoff=0.2,tension=0.8,fontsize = 14)


#############################################
#edgebundle example 3 (JSON file, for strucutre look at cran vignette)
filepath = system.file("sampleData", "flare-imports.json", package = "edgebundleR")
edgebundle(filepath,width=800,fontsize=8,tension=0.95)


#############################################
#edgebundle example 4 (save as web page)
ws_graph = watts.strogatz.game(1, 50, 4, 0.05)
edgebundle(ws_graph,tension = 0.1,fontsize = 20)
# g = edgebundle(ws_graph,tension = 0.1,fontsize = 20)
# saveEdgebundle(g,file = "ws_graph.html")









#################################### checking
petty <- read_html("http://www.psy.ohio-state.edu/petty/pubs.html")

# list of publications
pubs <- petty %>% 
  html_nodes("p") %>%
  html_text() 

# storing author names only
#Clear out characters that will create a problem with string extraction
pubs <- gsub("?",replacement = "",pubs)
pubs <- gsub("\\r",replacement = "",pubs)
pubs <- gsub("\\n",replacement = "",pubs)
pubs <- gsub("ñ",replacement = "n",pubs)

#Extract authors' names from citations
authors <- str_extract_all(pubs, pattern = "^[0-9]*[\\.\\)]{1}\\s[\\p{L}\\,\\.\\s\\&\\-]*[\\s\\(]", simplify = TRUE)

#Remove Initials
authors <- gsub("[A-Z][\\.\\,\\s]\\s{,3}?[A-Z\\.\\,]*?",replacement = "",authors)
#Remove Extra Commas
authors <- gsub("\\,\\s{,4}\\,",replacement = ",",authors)
authors <- gsub("\\,\\s\\.\\,",replacement = ",",authors)
#Remove Ampersands
authors <- gsub("\\,\\s{,3}\\&",replacement = ",",authors)
#Remove Trailing Parenthesis
authors <- gsub("[\\,\\.]\\s{,5}[A-Z]?\\s{,5}\\(",replacement = "",authors)
authors <- gsub("\\.\\s{1,3}\\,",replacement = ",",authors)
#Remove Numbers
authors <- gsub("^[0-9]*[\\.]?\\s{,4}[\\.]?",replacement = "",authors)
#Replace remaining periods with commas
authors <- gsub("\\.",replacement = ",",authors)
#Remove Empty Rows
authors <- data.frame(authors[nchar(authors[,1])>0], stringsAsFactors = FALSE)
names(authors) <- "authors"
print(xtable(head(authors)), type="html")












library(tidyverse)
library(viridis)
library(patchwork)
library(hrbrthemes)
library(ggraph)
library(igraph)

# The flare dataset is provided in ggraph
edges <- flare$edges
vertices <- flare$vertices %>% arrange(name) %>% mutate(name=factor(name, name))
connections <- flare$imports

# Preparation to draw labels properly:
vertices$id=NA
myleaves=which(is.na( match(vertices$name, edges$from) ))
nleaves=length(myleaves)
vertices$id[ myleaves ] = seq(1:nleaves)
vertices$angle= 90 - 360 * vertices$id / nleaves
vertices$hjust<-ifelse( vertices$angle < -90, 1, 0)
vertices$angle<-ifelse(vertices$angle < -90, vertices$angle+180, vertices$angle)

# Build a network object from this dataset:
mygraph <- graph_from_data_frame(edges, vertices = vertices)

# The connection object must refer to the ids of the leaves:
from = match( connections$from, vertices$name)
to = match( connections$to, vertices$name)

# Basic dendrogram
ggraph(mygraph, layout = 'dendrogram', circular = TRUE) + 
  geom_edge_link(size=0.4, alpha=0.1) +
  geom_node_text(aes(x = x*1.01, y=y*1.01, filter = leaf, label=shortName, angle = angle, hjust=hjust), size=1.5, alpha=1) +
  coord_fixed() +
  theme_void() +
  theme(
    legend.position="none",
    plot.margin=unit(c(0,0,0,0),"cm"),
  ) +
  expand_limits(x = c(-1.2, 1.2), y = c(-1.2, 1.2))











from_head = match( connections$from, vertices$name) %>% head(1)
to_head = match( connections$to, vertices$name) %>% head(1)

# Basic dendrogram
p1 <- ggraph(mygraph, layout = 'dendrogram', circular = TRUE) + 
  geom_edge_link(size=0.4, alpha=0.1) +
  geom_conn_bundle(data = get_con(from = from_head, to = to_head), alpha = 1, colour="#69b3a2", width=2, tension=0) + 
  geom_node_text(aes(x = x*1.01, y=y*1.01, filter = leaf, label=shortName, angle = angle, hjust=hjust), size=1.5, alpha=1) +
  coord_fixed() +
  theme_void() +
  theme(
    legend.position="none",
    plot.margin=unit(c(0,0,0,0),"cm"),
  ) +
  expand_limits(x = c(-1.2, 1.2), y = c(-1.2, 1.2))

p2 <- ggraph(mygraph, layout = 'dendrogram', circular = TRUE) + 
  geom_edge_link(size=0.4, alpha=0.1) +
  geom_conn_bundle(data = get_con(from = from_head, to = to_head), alpha = 1, colour="#69b3a2", width=2, tension=0.9) + 
  geom_node_text(aes(x = x*1.01, y=y*1.01, filter = leaf, label=shortName, angle = angle, hjust=hjust), size=1.5, alpha=1) +
  coord_fixed() +
  theme_void() +
  theme(
    legend.position="none",
    plot.margin=unit(c(0,0,0,0),"cm"),
  ) +
  expand_limits(x = c(-1.2, 1.2), y = c(-1.2, 1.2))

p1 + p2







# Make the plot
ggraph(mygraph, layout = 'dendrogram', circular = TRUE) + 
  geom_conn_bundle(data = get_con(from = from, to = to), alpha = 0.1, colour="#69b3a2") + 
  geom_node_text(aes(x = x*1.01, y=y*1.01, filter = leaf, label=shortName, angle = angle, hjust=hjust), size=1.5, alpha=1) +
  coord_fixed() +
  theme_void() +
  theme(
    legend.position="none",
    plot.margin=unit(c(0,0,0,0),"cm"),
  ) +
  expand_limits(x = c(-1.2, 1.2), y = c(-1.2, 1.2))