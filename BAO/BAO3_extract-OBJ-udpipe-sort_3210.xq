for $item in collection("sortieudpipe-slurp_3210.txt.xml")//item
where contains($item/a[8]/text(),'obj')
let $depforme:=$item/a[2]/text()
let $positionSource:=$item/a[1]
let $positionCible:=$item/a[7]
let $noeudC:=
   if (number($positionCible) < number($positionSource)) then (
		$item/preceding-sibling::item[number(a[1])=number($positionCible)]/a[2]/text()
	)
	else (
		$item/following-sibling::item[number(a[1])=number($positionCible)]/a[2]/text()
	)
let $preresu:= string-join(($noeudC,$depforme)," ")
group by $g:=$preresu
order by count($preresu) descending
return string-join(($g,count($preresu)),"&#9;")
