(: extraction des patrons :)

for $article in collection("sortiexml-slurp_TT_3232.txt.xml")//element
for $element in $article
let $catmatche:=if (($element/data[1]="NOM") and (contains($element/following-sibling::element[1]/data[1],"PRP")) and ($element/following-sibling::element[2]/data[1]="NOM") and ($element/following-sibling::element[3]/data[1]="PRP")) then (
  concat("NOM PRP NOM PRP: ", $element/data[3]/text(), " ",$element/following-sibling::element[1]/data[3]/text(), " ",$element/following-sibling::element[2]/data[3]/text(), " ",$element/following-sibling::element[3]/data[3]/text()  )
)
else if ((contains($element/data[1],"VER")) and (contains($element/following-sibling::element[1]/data[1],"DET")) and ($element/following-sibling::element[2]/data[1]="NOM")) then (
  concat("VER DET NOM : ", $element/data[3]/text(), " ",$element/following-sibling::element[1]/data[3]/text(), " ",$element/following-sibling::element[2]/data[3]/text())
)
else if (($element/data[1]="ADJ") and (contains($element/following-sibling::element[1]/data[1],"ADJ")) and ($element/following-sibling::element[2]/data[1]="NOM")) then (
  concat("ADJ ADJ NOM : ", $element/data[3]/text(), " ",$element/following-sibling::element[1]/data[3]/text(), " ",$element/following-sibling::element[2]/data[3]/text())
)
else if (($element/data[1]="ADJ") and (contains($element/following-sibling::element[1]/data[1],"NOM")) and ($element/following-sibling::element[2]/data[1]="NOM")) then (
  concat("ADJ NOM NOM : ", $element/data[3]/text(), " ",$element/following-sibling::element[1]/data[3]/text(), " ",$element/following-sibling::element[2]/data[3]/text())
)
else if (($element/data[1]="ADJ") and (contains($element/following-sibling::element[1]/data[1],"NOM"))) then (
  concat("ADJ NOM : ", $element/data[3]/text(), " ",$element/following-sibling::element[1]/data[3]/text())
)
else if (($element/data[1]="NOM") and (contains($element/following-sibling::element[1]/data[1],"ADJ"))) then (
  concat("NOM ADJ : ", $element/data[3]/text(), " ",$element/following-sibling::element[1]/data[3]/text())
)
  else ( "ca marche pas")
(: on ne gardera que les valeurs diféfrentes de "ca marche pas" :)
where $catmatche !="ca marche pas"
return $catmatche