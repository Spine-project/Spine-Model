# Do we need this file?

# Load required packaes
using Revise
using SpineModel
#using NamedArrays

# Export contents of database into the current session
db_url = "sqlite:///C:/Users/u0122387/Desktop/toolbox/projects/temporal_structure/input_timestorage/input_temporal2.sqlite"
JuMP_all_out(db_url)
##These Factors are only needed for the conversion from yyyy-mm-dd-hh-mm-ss to seconds
Conversion=[0,12,30,24,60,60]
Conversion2=[12,30,24,60,60,1]
### initilializing empty dicts
length_date = length(end_datetime()[:months])
start_time_in_sec = Dict()
end_time_in_sec = Dict()
start_time_in_sec_scale = Dict()
difference_end_start = Dict()
time_slices = Dict()
duration_in_sec = Dict()
###
m=1
kfirst=[]

###get durations in seconds:
for k in temporal_block()
   duration_in_sec[k] = 0
   for j=1:length(end_datetime()[k])
      duration_in_sec[k] = (duration_in_sec[k] + time_slice_duration()[k][j])*Conversion2[j]
   end
end

###here the loop over all temporal blocks starts
for k in temporal_block()
  start_time_in_sec[k] =0
  end_time_in_sec[k] = 0
  for j = 1:length_date
    start_time_in_sec[k] = (start_time_in_sec[k]  + start_datetime()[k][j])*Conversion2[j]
     end_time_in_sec[k] = (end_time_in_sec[k]  + end_datetime()[k][j])*Conversion2[j]
  end
  start_time_in_sec_scale[k] = start_time_in_sec[k]
  if m ==1
  @show kfirst = k
  end
  start_time_in_sec[k]=start_time_in_sec[k] - start_time_in_sec_scale[kfirst]
  end_time_in_sec[k] = end_time_in_sec[k] - start_time_in_sec_scale[kfirst]
  m=m+1
end
### generate seconds timesteps

for k in temporal_block()
   difference_end_start[k] = end_time_in_sec[k] - start_time_in_sec[k]
   n= ceil(difference_end_start[k]/duration_in_sec[k])
   i= 1
   time_slices[k] = zeros(n+1)
   time_slices[k][i] = start_time_in_sec[k]

   while difference_end_start[k] >0
      i=i+1
      time_slices[k][i] = time_slices[k][i-1] + duration_in_sec[k]
      difference_end_start[k]= difference_end_start[k]- duration_in_sec[k]
   end
end

for k in temporal_block()
   i[m] = duration_in_sec[k]
for k1 in temporal_block()
   for k2 in temporal_block()
      for i = 1:length(time_slices[k1])
         for j = 1:length(time_slices[k2])
            @show difference = (time_slices[k1][i]-time_slices[k2][j])
         end
      end

end
end



#=
  ## the difference_in_sec and the duration_in_sec are only needed for looping lateron
  difference_in_sec = 0
  duration_in_sec =0
  ### lengthdate = this is the count of the 6 hierarchical levels namely (year,month,day,hour,minute,sec)=6
  length_date = length(end_datetime()[k])
  ### difference between the start and the enddate in [yyyy,mm,dd,hh,mm,ss]-format
  difference_start_end[k]  = end_datetime()[k] - start_datetime()[k]
  ## here the initial timeslice is introduced = the beginning of the timeblock
  time_slices[k,1] = start_datetime()[k]

  ###here the loop over year,month,day,hour,minute,sec starts
  for j = 1:length_date
    ### aslong as one level delivers a negative value e.g. -15 seconds, it gets +60, minutes are reduced by one
    while difference_start_end[k][(length_date-j+1)] <0
      difference_start_end[k][(length_date-j+1)] = difference_start_end[k][(length_date-j+1)] + Conversion[(length_date-j+1)]
      difference_start_end[k][(length_date-j)] = difference_start_end[k][(length_date-j)] -1
    end
    #the duration_in_sec and the difference_in_sec for the corresponding termpoal_block are calculated iteratively
    duration_in_sec = (duration_in_sec + time_slice_duration()[k][j])*Conversion2[j]
    difference_in_sec = (difference_in_sec  + difference_start_end[k][j])*Conversion2[j]
  end
  i=1
  named_time_slices[k,i]="t_$(time_slices[k,i][1])"
  for j=2:length_date
    @show named_time_slices[k,i] = "$(named_time_slices[k,i])_$(time_slices[k,i][j])"
  end
###
  while difference_in_sec > 0
    i=i+1
    difference_in_sec = difference_in_sec - duration_in_sec
    time_slices[k,i] =  time_slices[k,i-1] + time_slice_duration()[k]
      for j = 1:length_date-1
        while time_slices[k,i][(length_date-j+1)] > Conversion[(length_date-j+1)]
          time_slices[k,i][(length_date-j+1)] = time_slices[k,i][(length_date-j+1)] - Conversion[(length_date-j+1)]
          time_slices[k,i][(length_date-j)] =  time_slices[k,i][(length_date-j)] +1
        end
      end
      named_time_slices[k,i] = "t_$(time_slices[k,i][1])"
      for j =2:length_date
        @show named_time_slices[k,i] = "$(named_time_slices[k,i])_$(time_slices[k,i][j])"
      end
  end
end

##
#= all timeslices that have some time in common?
- erst checken start date end date -> ist ex überhaupt möglich dass sie zeit geminsam haben
- dann jahre gucken, monate, tage, ...
- dann dijegenidgen auswählen die da rein passen
=# ## directly subsequent?
=#
