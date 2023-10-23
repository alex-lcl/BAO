(: extraction du patron NOM PRP NOM PRP :)

for $article in collection("sortiexml-slurp_TT_3210.txt.xml")//element
for $element in $article
let $catmatche:=if (($element/data[1]="NOM") and (contains($element/following-sibling::element[1]/data[1],"PRP")) and ($element/following-sibling::element[2]/data[1]="NOM") and ($element/following-sibling::element[3]/data[1]="PRP")) then (
  concat("NOM PRP NOM PRP: ", $element/data[3]/text(), " ",$element/following-sibling::element[1]/data[3]/text(), " ",$element/following-sibling::element[2]/data[3]/text(), " ",$element/following-sibling::element[3]/data[3]/text()  )
)
  else ( "ca marche pas")
(: on ne gardera que les valeurs diféfrentes de "ca marche pas" :)
where $catmatche !="ca marche pas"
return $catmatche