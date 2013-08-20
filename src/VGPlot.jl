using Vega
using DataFrames

module VGPlot
	using Vega
	using DataFrames

	export vgplot
	export geom_point, geom_line, geom_bar, geom_text

	type geom_point
		size::Float64
		shape::String
	end
	function geom_point(; size::Real = NaN,
		                  shape::String = "")
		geom_point(float64(size), shape)
	end
	type geom_line
	end
	type geom_bar
	end

	function Vega.VegaData(df::DataFrame)
		n_in, p_in = size(df)
		df = df[complete_cases(df), :]
		n, p = size(df)
		# TODO: Make this depend on desired columns
		if n_in - n != 0
			@printf "Removing %d rows with missing values\n" n_in - n
		end
		names = colnames(df)
		values = Array(Dict{Any, Any}, n)
		for i in 1:n
			d = Dict{Any, Any}()
			for j in 1:p
				d[names[j]] = df[i, j]
			end
			values[i] = d
		end
		return VegaData(values = values)
	end

	function vgplot(df::DataFrame;
		            x::String = "x",
		            y::String = "y",
		            group::String = "group",
		            scalex::String = "linear",
		            scaley::String = "linear")
		if !haskey(df, x)
			# @printf "Input data does not have a column named %s\n" x
			df[x] = ones(Int, size(df, 1))
		end
		if !haskey(df, y)
			# @printf "Input data does not have a column named %s\n" y
			df[y] = ones(Int, size(df, 1))
		end
		if !haskey(df, group)
			# @printf "Input data does not have a column named %s\n" group
			df[group] = ones(Int, size(df, 1))
		end
		data = [VegaData(df)]
		scales = Array(VegaScale, 3)
		scales[1] = VegaScale(name = "x",
			                  _type = scalex,
			                  range = "width",
		                      domain = VegaDataRef("table", string("data.", x)))
		scales[2] = VegaScale(name = "y",
			                  _type = scaley,
			                  range = "height",
		                      domain = VegaDataRef("table", string("data.", y)))
		scales[3] = VegaScale(name = "group",
			                  _type = "ordinal",
			                  range = "category10",
		                      domain = VegaDataRef("table", string("data.", group)))
	    v = VegaVisualization(data = data,
		                      scales = scales)
	    axis1 = VegaAxis(_type = "x", scale = "x", title = "x")
	    axis2 = VegaAxis(_type = "y", scale = "y", title = "y")
	    v.axes = [axis1, axis2]
	    v.legends = [{"fill" => "group", "title" => "Group"}]
    	return v
	end

	# Need to use proper field labels here
	# Need to clean column names because Vega treats "." as semantic
	function Base.(:+)(v::VegaVisualization, p::geom_point)
		xfield = v.scales[1].domain.field
		yfield = v.scales[2].domain.field
		groupfield = v.scales[3].domain.field
		v = copy(v)
		enterprops =
		 VegaMarkPropertySet(x = VegaValueRef(scale = "x",
		 	                                  field = xfield),
	                         y = VegaValueRef(scale = "y",
	                         	              field = yfield),
	                         stroke = VegaValueRef(scale = "group",
	                         	                   field = groupfield),
	                         fill = VegaValueRef(scale = "group",
	                         	                 field = groupfield),
	                         fillOpacity = VegaValueRef(value = 0.5))
		if !isnan(p.size)
			enterprops.size = VegaValueRef(value = p.size)
		end
		if !isempty(p.shape)
			enterprops.shape = VegaValueRef(value = p.shape)
		end
		if v.marks == nothing
			v.marks = VegaMark[]
		end
	    push!(v.marks, VegaMark(_type = "symbol",
	                            from = {"data" => "table"},
	                            properties = VegaMarkProperties(enter = enterprops)))
	    return v
	end

	# Need to use proper field labels here
	# Need to clean column names because Vega treats "." as semantic
	function Base.(:+)(v::VegaVisualization, p::geom_line)
		xfield = v.scales[1].domain.field
		yfield = v.scales[2].domain.field
		groupfield = v.scales[3].domain.field
		v = copy(v)
	    enterprops =
	      VegaMarkPropertySet(x = VegaValueRef(scale = "x",
	                                           field = xfield),
	                          y = VegaValueRef(scale = "y",
	                                           field = yfield),
	                          stroke = VegaValueRef(scale = "group",
	                                                field = groupfield))
	    innermarks = Array(VegaMark, 1)
	    innermarks[1] = VegaMark(_type = "line",
	                             properties =
	                               VegaMarkProperties(enter = enterprops))
		if v.marks == nothing
			v.marks = VegaMark[]
		end
	    push!(v.marks, VegaMark(_type = "group",
	                            from = {
	                                    "data" => "table",
	                                    "transform" => [{"type" => "facet", "keys" => ["data.group"]}]
	                                   },
	                            marks = innermarks))
	    return v
	end

	# Need to use proper field labels here
	# Need to clean column names because Vega treats "." as semantic
	function Base.(:+)(v::VegaVisualization, p::geom_bar)
		xfield = v.scales[1].domain.field
		yfield = v.scales[2].domain.field
		groupfield = v.scales[3].domain.field
		v = copy(v)
		enterprops =
		  VegaMarkPropertySet(x = VegaValueRef(scale = "x",
		  	                                  field = xfield),
	                          width = VegaValueRef(scale = "x",
	                          	                  band = true,
	                          	                  offset = -1),
	                          y = VegaValueRef(scale = "y",
	                          	              field = yfield),
	                          y2 = VegaValueRef(value = 0),
	                          stroke = VegaValueRef(scale = "group",
	                                                field = groupfield),
	                          fill = VegaValueRef(scale = "group",
	                          	                 field = groupfield),
	                          fillOpacity = VegaValueRef(value = 0.5))
		if v.marks == nothing
			v.marks = VegaMark[]
		end
	    push!(v.marks, VegaMark(_type = "rect",
	                            from = {"data" => "table"},
	                            properties =
	                              VegaMarkProperties(enter = enterprops)))
	    return v
	end
end
