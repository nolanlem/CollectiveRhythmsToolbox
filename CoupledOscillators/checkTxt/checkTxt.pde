String[] lines = loadStrings("../savedstates/here.txt");
println("there are " + lines.length + " lines");
for(int i = 0; i <lines.length; i++){
  println(lines[i]);
}
