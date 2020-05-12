foreach ($f in (Get-ChildItem '.\ShadersToProcess'))
{
	.\process.py $f.FullName
}
