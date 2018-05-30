#!/usr/bin/gawk -f
# vim: syntax=awk tabstop=4
BEGIN {
		"hash tput 2>/dev/null && tput cols || echo 80" |& getline maxlen["term"]
		heading_names="Subvolume"
		heading_total="Total"
		heading_exclusive="Exclusive"
		heading_id="ID"

		maxlen["names"] = length(heading_names)
		maxlen["totals"] = length(heading_total)
		maxlen["exclusive"] = length(heading_exclusive)
		maxlen["id"] = length(heading_id)
}

FNR<=2 { next }

function getdashes(width) {
		s=sprintf("%"width"s","")
		gsub(/ /,"─",s)
		return s
}

function trimsubs(width) {
		for (i in names) {
				if (names[i] ~ /.*\//)
						trimpaths(i)

				if (length(names[i]) > width)
						names[i]=substr(names[i],0,width -4)"[..]"
		}
		maxlen["names"]=width
}

function trimpaths(idx) {
		count=split(names[idx],dirs,"/")
		trimmed=""

		for (j in dirs) {
				if (length(dirs[j]) > 16)
						dirs[j]=substr(dirs[j],0,12)"[..]"

				if (j == count)
						trimmed=trimmed dirs[j]
				else
						trimmed=trimmed dirs[j]"/"
		}
		names[idx]=trimmed
}

function readable(size) {
		count=0
		while (size > 1023) {
				count++
				size=size/1024
		}

		if (count==4)
				suff="TiB"
		else if (count==3)
				suff="GiB"
		else if (count==2)
				suff="MiB"
		else if (count==1)
				suff="KiB"
		else
				suff="B"

		return sprintf("%.2f%s", size, suff)
}

#FNR==NR && /^[[:digit:]]+\s+[[:digit:]]+\s+[[:digit:]]+\s+.*\// {
#	names[$1]=trimpaths($4)
#	next
#}

FNR==NR {
		names[$1]=$4

		if (length(names[$1]) > maxlen["names"])
				maxlen["names"]=length(names[$1])

		if (length($1) > maxlen["id"])
				maxlen["id"]=length($1)
		next
}

/[[:digit:]]+\/[[:digit:]]+\s+/ {
		split($1,ids,"/")

		exclusivetotal+=$3

		exclusive[ids[2]]=readable($3)
		if (length(exclusive[ids[2]]) > maxlen["exclusive"])
				maxlen["exclusive"]=length(exclusive[ids[2]])

		totals[ids[2]]=readable($2)
		if (length(totals[ids[2]]) > maxlen["totals"])
				maxlen["totals"]=length(totals[ids[2]])
}

END {
		pathwidth=maxlen["term"] - maxlen["totals"] - maxlen["exclusive"] - maxlen["id"] - 6

		trimsubs(pathwidth)

		totalwidth=maxlen["id"] + maxlen["totals"] + maxlen["exclusive"] + maxlen["names"] + 6
		
		fmtstring="%-"maxlen["names"]"s  %"maxlen["totals"]"s  %"maxlen["exclusive"]"s  %"maxlen["id"]"s\n"
		printf fmtstring,heading_names,heading_total,heading_exclusive,heading_id
		dashes=getdashes(totalwidth)
		print dashes

		for (i in names)
				printf fmtstring,names[i],totals[i],exclusive[i],i

		print dashes
		printf fmtstring,"Exclusive Total:","",readable(exclusivetotal),""
}
