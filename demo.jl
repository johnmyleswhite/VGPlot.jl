using VGPlot

df = DataFrame()
df["x"] = 0.0:0.1:(2.0 * pi)
df["y"] = sin(df["x"]) + sin(2 * df["x"]) + sin(3 * df["x"])

vgplot(df)

vgplot(df) + geom_point()

vgplot(df) + geom_line()

vgplot(df) + geom_point() + geom_line()

vgplot(df) +
  geom_point(size = 10.0, shape = "diamond") +
  geom_line()

vgplot(df) +
  geom_point(size = 25.0, shape = "cross") +
  geom_line()

using RDatasets

iris = data("datasets", "iris")
clean_colnames!(iris)

v = vgplot(iris,
	       x = "Sepal_Length",
	       y = "Sepal_Width",
	       group = "Species")

v = v + geom_point()

v = v + geom_line()
