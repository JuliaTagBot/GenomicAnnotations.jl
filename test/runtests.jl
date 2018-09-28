using GenomicAnnotations
using Test

@testset "GenomicAnnotations" begin
    chr = readgbk("example.gbk")
    @test length(chr) == 1
    chr = chr[1]

    @testset "Gene properties" begin
        @test chr.genes[2].locus_tag == "tag01"
        @test (chr.genes[2].locus_tag = "tag01") == "tag01"
        @test begin
            chr.genes[2].test = "New column"
            chr.genes[2].test == "New column" && all(ismissing, chr.genes[[1,3,4,5,6]].test)
        end
        @test get(chr.genes[2], :locus_tag, "") == "tag01"
        @test get(chr.genes[2], :locustag, "") == ""
        @test begin
            GenomicAnnotations.pushproperty!(chr.genes[2], :db_xref, "GI:123")
            chr.genes[2].db_xref == ["GI:1293614", "GI:123"]
        end
    end

    @testset "Iteration" begin
        @test length([g.locus_tag for g in chr.genes]) == 6
    end

    @testset "Adding/removing genes" begin
        addgene!(chr, "CDS", Locus(300:390, '+'), locus_tag = "tag04")
        @test chr.genes[end].locus_tag == "tag04"
        delete!(chr.genes[end])
        @test chr.genes[end].locus_tag == "tag03"
    end

    @testset "@genes" begin
        @test @genes(chr, :feature == "CDS") == chr.genes[[2,4,6]]
        @test @genes(chr, iscomplement(gene)) == chr.genes[[5,6]]
        @test @genes(chr, :feature == "CDS", !iscomplement(gene)) == chr.genes[[2,4]]
        @test @genes(chr, length(gene) < 300)[1] == chr.genes[2]
    end

    @testset "Locus" begin
        locus = Locus(1:1, '.', true, true, UnitRange{Int}[])
        @test Locus() == locus
        @test chr.genes[2].locus < chr.genes[4].locus
        @test chr.genes[2].locus == chr.genes[2].locus
    end

    seq = "atgtccatatacaacggtatctccacctcaggtttagatctcaacaacggaaccattgccgacatgagacagttaggtatcgtcgagagttacaagctaaaacgagcagtagtcagctctgcatctgaagccgctgaagttctactaagggtggataacatcatccgtgcaagaccaagaaccgccaatagacaacatatgtaa"
    @test genesequence(chr.genes[2]) == seq
    @test length(chr.genes[2]) == length(seq)
end