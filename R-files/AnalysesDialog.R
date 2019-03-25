BasisAnalyses <- function(){
  # read in files
  setwd('currentSimulation')
  
  results.PFT <- fread("resultsPFT.txt", sep="\t", header=T)
  setkey(results.PFT, PFT, Time, scenario, year, week, period)
  # effect per timestep
  effect.timestep.PFT <- results.PFT[,.(mean.effects.Inds = mean(Inds), mean.effects.seedlings = mean(seedlings), mean.effects.seeds = mean(seeds),
                               mean.effects.cover = mean(cover), mean.effects.shootmass = mean(shootmass),
                               min.effects.Inds = quantile(Inds, probs=0.925),
                               min.effects.seedlings = quantile(seedlings, probs=0.925), min.effects.seeds = quantile(seeds, probs=0.925),
                               min.effects.cover = quantile(cover, probs=0.925), min.effects.shootmass =quantile(shootmass, probs=0.925)
                               # min
                               , max.effects.Inds = quantile(Inds, probs=0.025),
                               max.effects.seedlings = quantile(seedlings, probs=0.025), max.effects.seeds = quantile(seeds, probs=0.025),
                               max.effects.cover = quantile(cover, probs=0.025), max.effects.shootmass =quantile(shootmass, probs=0.025)) ,
                               by=.(Time, PFT, scenario, period, year, week)]
  fwrite(effect.timestep.PFT, "effect.timestep.PFT.txt", sep="\t")
  # effect per year
  effect.year.PFT <- results.PFT[,.(mean.effects.Inds = mean(Inds), mean.effects.seedlings = mean(seedlings), mean.effects.seeds = mean(seeds),
                                    mean.effects.cover = mean(cover), mean.effects.shootmass = mean(shootmass),
                                    min.effects.Inds = quantile(Inds, probs=0.925),
                                    min.effects.seedlings = quantile(seedlings, probs=0.925), min.effects.seeds = quantile(seeds, probs=0.925),
                                    min.effects.cover = quantile(cover, probs=0.925), min.effects.shootmass =quantile(shootmass, probs=0.925)
                                    # min
                                    , max.effects.Inds = quantile(Inds, probs=0.025),
                                    max.effects.seedlings = quantile(seedlings, probs=0.025), max.effects.seeds = quantile(seeds, probs=0.025),
                                    max.effects.cover = quantile(cover, probs=0.025), max.effects.shootmass =quantile(shootmass, probs=0.025)) ,
                                 by=.(PFT, scenario, year, period)]
  fwrite(effect.year.PFT, "effect.year.PFT.txt", sep="\t")
  
  # Tables
  Inds<-effect.timestep.PFT[,.(mean.10=length(which((mean.effects.Inds*-1+1)>=0 & (mean.effects.Inds*-1+1)<=0.1))
              , min.10=length(which((min.effects.Inds*-1+1)>=0 & (min.effects.Inds*-1+1)<=0.1))
              , max.10=length(which((max.effects.Inds*-1+1)>=0 & (max.effects.Inds*-1+1)<=0.1))
              , mean.10_20=length(which((mean.effects.Inds*-1+1)>0.1 & (mean.effects.Inds*-1+1)<=0.2))
              , min.10_20=length(which((min.effects.Inds*-1+1)>0.1 & (min.effects.Inds*-1+1)<=0.2))
              , max.10_20=length(which((max.effects.Inds*-1+1)>0.1 & (max.effects.Inds*-1+1)<=0.2))
              , mean.20_30=length(which((mean.effects.Inds*-1+1)>0.2 & (mean.effects.Inds*-1+1)<=0.3))
              , min.20_30=length(which((min.effects.Inds*-1+1)>0.2 & (min.effects.Inds*-1+1)<=0.3))
              , max.20_30=length(which((max.effects.Inds*-1+1)>0.2 & (max.effects.Inds*-1+1)<=0.3))
              , mean.30_40=length(which((mean.effects.Inds*-1+1)>0.3 & (mean.effects.Inds*-1+1)<=0.4))
              , min.30_40=length(which((min.effects.Inds*-1+1)>0.3 & (min.effects.Inds*-1+1)<=0.4))
              , max.30_40=length(which((max.effects.Inds*-1+1)>0.3 & (max.effects.Inds*-1+1)<=0.4))
              , mean.40_50=length(which((mean.effects.Inds*-1+1)>0.4 & (mean.effects.Inds*-1+1)<=0.5))
              , min.40_50=length(which((min.effects.Inds*-1+1)>0.4 & (min.effects.Inds*-1+1)<=0.5))
              , max.40_50=length(which((max.effects.Inds*-1+1)>0.4 & (max.effects.Inds*-1+1)<=0.5))
              , mean.50=length(which((mean.effects.Inds*-1+1)>0.5))
              , min.50=length(which((min.effects.Inds*-1+1)>0.5))
              , max.50=length(which((max.effects.Inds*-1+1)>0.5))), by=.(scenario, PFT, year)]
  colnames(Inds) <- c("Application rate", colnames(Inds)[-1])
  #
  shootmass<-effect.timestep.PFT[, .(mean.10=length(which((mean.effects.shootmass*-1+1)>=0 & (mean.effects.shootmass*-1+1)<=0.1))
                   , min.10=length(which((min.effects.shootmass*-1+1)>=0 & (min.effects.shootmass*-1+1)<=0.1))
                   , max.10=length(which((max.effects.shootmass*-1+1)>=0 & (max.effects.shootmass*-1+1)<=0.1))
                   , mean.10_20=length(which((mean.effects.shootmass*-1+1)>0.1 & (mean.effects.shootmass*-1+1)<=0.2))
                   , min.10_20=length(which((min.effects.shootmass*-1+1)>0.1 & (min.effects.shootmass*-1+1)<=0.2))
                   , max.10_20=length(which((max.effects.shootmass*-1+1)>0.1 & (max.effects.shootmass*-1+1)<=0.2))
                   , mean.20_30=length(which((mean.effects.shootmass*-1+1)>0.2 & (mean.effects.shootmass*-1+1)<=0.3))
                   , min.20_30=length(which((min.effects.shootmass*-1+1)>0.2 & (min.effects.shootmass*-1+1)<=0.3))
                   , max.20_30=length(which((max.effects.shootmass*-1+1)>0.2 & (max.effects.shootmass*-1+1)<=0.3))
                   , mean.30_40=length(which((mean.effects.shootmass*-1+1)>0.3 & (mean.effects.shootmass*-1+1)<=0.4))
                   , min.30_40=length(which((min.effects.shootmass*-1+1)>0.3 & (min.effects.shootmass*-1+1)<=0.4))
                   , max.30_40=length(which((max.effects.shootmass*-1+1)>0.3 & (max.effects.shootmass*-1+1)<=0.4))
                   , mean.40_50=length(which((mean.effects.shootmass*-1+1)>0.4 & (mean.effects.shootmass*-1+1)<=0.5))
                   , min.40_50=length(which((min.effects.shootmass*-1+1)>0.4 & (min.effects.shootmass*-1+1)<=0.5))
                   , max.40_50=length(which((max.effects.shootmass*-1+1)>0.4 & (max.effects.shootmass*-1+1)<=0.5))
                   , mean.50=length(which((mean.effects.shootmass*-1+1)>0.5))
                   , min.50=length(which((min.effects.shootmass*-1+1)>0.5))
                   , max.50=length(which((max.effects.shootmass*-1+1)>0.5))), by=.(scenario, PFT, year)]
  colnames(shootmass) <- c("Application rate", colnames(shootmass)[-1])
  #
  cover<-effect.timestep.PFT[, .(mean.10=length(which((mean.effects.cover*-1+1)>=0 & (mean.effects.cover*-1+1)<=0.1))
               , min.10=length(which((min.effects.cover*-1+1)>=0 & (min.effects.cover*-1+1)<=0.1))
               , max.10=length(which((max.effects.cover*-1+1)>=0 & (max.effects.cover*-1+1)<=0.1))
               , mean.10_20=length(which((mean.effects.cover*-1+1)>0.1 & (mean.effects.cover*-1+1)<=0.2))
               , min.10_20=length(which((min.effects.cover*-1+1)>0.1 & (min.effects.cover*-1+1)<=0.2))
               , max.10_20=length(which((max.effects.cover*-1+1)>0.1 & (max.effects.cover*-1+1)<=0.2))
               , mean.20_30=length(which((mean.effects.cover*-1+1)>0.2 & (mean.effects.cover*-1+1)<=0.3))
               , min.20_30=length(which((min.effects.cover*-1+1)>0.2 & (min.effects.cover*-1+1)<=0.3))
               , max.20_30=length(which((max.effects.cover*-1+1)>0.2 & (max.effects.cover*-1+1)<=0.3))
               , mean.30_40=length(which((mean.effects.cover*-1+1)>0.3 & (mean.effects.cover*-1+1)<=0.4))
               , min.30_40=length(which((min.effects.cover*-1+1)>0.3 & (min.effects.cover*-1+1)<=0.4))
               , max.30_40=length(which((max.effects.cover*-1+1)>0.3 & (max.effects.cover*-1+1)<=0.4))
               , mean.40_50=length(which((mean.effects.cover*-1+1)>0.4 & (mean.effects.cover*-1+1)<=0.5))
               , min.40_50=length(which((min.effects.cover*-1+1)>0.4 & (min.effects.cover*-1+1)<=0.5))
               , max.40_50=length(which((max.effects.cover*-1+1)>0.4 & (max.effects.cover*-1+1)<=0.5))
               , mean.50=length(which((mean.effects.cover*-1+1)>0.5))
               , min.50=length(which((min.effects.cover*-1+1)>0.5))
               , max.50=length(which((max.effects.cover*-1+1)>0.5))), by=.(scenario, PFT, year)]
  colnames(cover) <- c("Application rate", colnames(cover)[-1])
  #
  fwrite(Inds, "Inds_PFT.txt", sep="\t")
  fwrite(shootmass, "shootmass_PFT.txt", sep="\t")
  fwrite(cover, "cover_PFT.txt", sep="\t")
  rm(results.PFT, effect.timestep.PFT, effect.year.PFT, Inds, shootmass, cover)
  gc()
  
  results.GRD <- fread("resultsGRD.txt", sep="\t", header=T)
  # results.GRD[is.infinite(results.GRD)] <-0
  setkey(results.GRD,Time, scenario, year, week, period)
  # effect per time step
  effect.timestep.GRD <- results.GRD[, .(mean.effects.Inds = mean(NInd), mean.effects.abovemass = mean(abovemass), mean.effects.NPFT = mean(NPFT)
                                    , mean.effects.eveness = mean(eveness), mean.effects.shannon = mean(shannon), mean.effects.simpson = mean(simpson), mean.effects.simpsoninv = mean(simpsoninv, na.rm=T)
                                    # min
                                    , min.effects.Inds = quantile(NInd, probs=0.925), min.effects.abovemass = quantile(abovemass, probs=0.925), min.effects.NPFT = quantile(NPFT, probs=0.925)
                                    , min.effects.eveness = quantile(eveness, probs=0.925, na.rm=T), min.effects.shannon = quantile(shannon, probs=0.925, na.rm=T), min.effects.simpson = quantile(simpson, probs=0.925, na.rm=T),
                                    min.effects.simpsoninv = quantile(simpsoninv, probs=0.925, na.rm=T)
                                    # max
                                    , max.effects.Inds = quantile(NInd, probs=0.025), max.effects.abovemass = quantile(abovemass, probs=0.025), max.effects.NPFT = quantile(NPFT, probs=0.025)
                                    , max.effects.eveness = quantile(eveness, probs=0.025, na.rm=T), max.effects.shannon = quantile(shannon, probs=0.025, na.rm=T), 
                                    max.effects.simpson = quantile(simpson, probs=0.025, na.rm=T), 
                                    max.effects.simpsoninv = quantile(simpsoninv, probs=0.025, na.rm=T)), by=.(Time, scenario, period, year, week)]
  fwrite(effect.timestep.GRD, "effect.timestep.GRD.txt", sep="\t")
  # effect per year
  effect.year.GRD <- results.GRD[, .(mean.effects.Inds = mean(NInd), mean.effects.abovemass = mean(abovemass), mean.effects.NPFT = mean(NPFT)
                           , mean.effects.eveness = mean(eveness), mean.effects.shannon = mean(shannon), mean.effects.simpson = mean(simpson), mean.effects.simpsoninv = mean(simpsoninv)
                           # min
                           , min.effects.Inds = quantile(NInd, probs=0.925), min.effects.abovemass = quantile(abovemass, probs=0.925), min.effects.NPFT = quantile(NPFT, probs=0.925)
                           , min.effects.eveness = quantile(eveness, probs=0.925, na.rm=T), min.effects.shannon = quantile(shannon, probs=0.925, na.rm=T), 
                           min.effects.simpson = quantile(simpson, probs=0.925, na.rm=T), min.effects.simpsoninv = quantile(simpsoninv, probs=0.925, na.rm=T)
                           # max
                           , max.effects.Inds = quantile(NInd, probs=0.025), max.effects.abovemass = quantile(abovemass, probs=0.025), max.effects.NPFT = quantile(NPFT, probs=0.025)
                           , max.effects.eveness = quantile(eveness, probs=0.025, na.rm=T), max.effects.shannon = quantile(shannon, probs=0.025, na.rm=T), 
                           max.effects.simpson = quantile(simpson, probs=0.025, na.rm=T), max.effects.simpsoninv = quantile(simpsoninv, probs=0.025, na.rm=T) 
                           ), by=.(scenario, year, period)]
  fwrite(effect.year.GRD, "effect.year.GRD.txt", sep="\t")
  # tables
  NPFT<-effect.timestep.GRD[, .(mean.10=length(which((mean.effects.NPFT*-1+1)>=0 & (mean.effects.NPFT*-1+1)<=0.1))
              , min.10=length(which((min.effects.NPFT*-1+1)>=0 & (min.effects.NPFT*-1+1)<=0.1))
              , max.10=length(which((max.effects.NPFT*-1+1)>=0 & (max.effects.NPFT*-1+1)<=0.1))
              , mean.10_20=length(which((mean.effects.NPFT*-1+1)>0.1 & (mean.effects.NPFT*-1+1)<=0.2))
              , min.10_20=length(which((min.effects.NPFT*-1+1)>0.1 & (min.effects.NPFT*-1+1)<=0.2))
              , max.10_20=length(which((max.effects.NPFT*-1+1)>0.1 & (max.effects.NPFT*-1+1)<=0.2))
              , mean.20_30=length(which((mean.effects.NPFT*-1+1)>0.2 & (mean.effects.NPFT*-1+1)<=0.3))
              , min.20_30=length(which((min.effects.NPFT*-1+1)>0.2 & (min.effects.NPFT*-1+1)<=0.3))
              , max.20_30=length(which((max.effects.NPFT*-1+1)>0.2 & (max.effects.NPFT*-1+1)<=0.3))
              , mean.30_40=length(which((mean.effects.NPFT*-1+1)>0.3 & (mean.effects.NPFT*-1+1)<=0.4))
              , min.30_40=length(which((min.effects.NPFT*-1+1)>0.3 & (min.effects.NPFT*-1+1)<=0.4))
              , max.30_40=length(which((max.effects.NPFT*-1+1)>0.3 & (max.effects.NPFT*-1+1)<=0.4))
              , mean.40_50=length(which((mean.effects.NPFT*-1+1)>0.4 & (mean.effects.NPFT*-1+1)<=0.5))
              , min.40_50=length(which((min.effects.NPFT*-1+1)>0.4 & (min.effects.NPFT*-1+1)<=0.5))
              , max.40_50=length(which((max.effects.NPFT*-1+1)>0.4 & (max.effects.NPFT*-1+1)<=0.5))
              , mean.50=length(which((mean.effects.NPFT*-1+1)>0.5))
              , min.50=length(which((min.effects.NPFT*-1+1)>0.5))
              , max.50=length(which((max.effects.NPFT*-1+1)>0.5))), by=.(scenario, year)]
  colnames(NPFT) <- c("Application rate", colnames(NPFT)[-1])
  
  Inds<-effect.timestep.GRD[, .(mean.10=length(which((mean.effects.Inds*-1+1)>=0 & (mean.effects.Inds*-1+1)<=0.1))
              , min.10=length(which((min.effects.Inds*-1+1)>=0 & (min.effects.Inds*-1+1)<=0.1))
              , max.10=length(which((max.effects.Inds*-1+1)>=0 & (max.effects.Inds*-1+1)<=0.1))
              , mean.10_20=length(which((mean.effects.Inds*-1+1)>0.1 & (mean.effects.Inds*-1+1)<=0.2))
              , min.10_20=length(which((min.effects.Inds*-1+1)>0.1 & (min.effects.Inds*-1+1)<=0.2))
              , max.10_20=length(which((max.effects.Inds*-1+1)>0.1 & (max.effects.Inds*-1+1)<=0.2))
              , mean.20_30=length(which((mean.effects.Inds*-1+1)>0.2 & (mean.effects.Inds*-1+1)<=0.3))
              , min.20_30=length(which((min.effects.Inds*-1+1)>0.2 & (min.effects.Inds*-1+1)<=0.3))
              , max.20_30=length(which((max.effects.Inds*-1+1)>0.2 & (max.effects.Inds*-1+1)<=0.3))
              , mean.30_40=length(which((mean.effects.Inds*-1+1)>0.3 & (mean.effects.Inds*-1+1)<=0.4))
              , min.30_40=length(which((min.effects.Inds*-1+1)>0.3 & (min.effects.Inds*-1+1)<=0.4))
              , max.30_40=length(which((max.effects.Inds*-1+1)>0.3 & (max.effects.Inds*-1+1)<=0.4))
              , mean.40_50=length(which((mean.effects.Inds*-1+1)>0.4 & (mean.effects.Inds*-1+1)<=0.5))
              , min.40_50=length(which((min.effects.Inds*-1+1)>0.4 & (min.effects.Inds*-1+1)<=0.5))
              , max.40_50=length(which((max.effects.Inds*-1+1)>0.4 & (max.effects.Inds*-1+1)<=0.5))
              , mean.50=length(which((mean.effects.Inds*-1+1)>0.5))
              , min.50=length(which((min.effects.Inds*-1+1)>0.5))
              , max.50=length(which((max.effects.Inds*-1+1)>0.5))), by=.(scenario, year)]
  colnames(Inds) <- c("Application rate", colnames(Inds)[-1])
  
  abovemass<-effect.timestep.GRD[, .(mean.10=length(which((mean.effects.abovemass*-1+1)>=0 & (mean.effects.abovemass*-1+1)<=0.1))
                   , min.10=length(which((min.effects.abovemass*-1+1)>=0 & (min.effects.abovemass*-1+1)<=0.1))
                   , max.10=length(which((max.effects.abovemass*-1+1)>=0 & (max.effects.abovemass*-1+1)<=0.1))
                   , mean.10_20=length(which((mean.effects.abovemass*-1+1)>0.1 & (mean.effects.abovemass*-1+1)<=0.2))
                   , min.10_20=length(which((min.effects.abovemass*-1+1)>0.1 & (min.effects.abovemass*-1+1)<=0.2))
                   , max.10_20=length(which((max.effects.abovemass*-1+1)>0.1 & (max.effects.abovemass*-1+1)<=0.2))
                   , mean.20_30=length(which((mean.effects.abovemass*-1+1)>0.2 & (mean.effects.abovemass*-1+1)<=0.3))
                   , min.20_30=length(which((min.effects.abovemass*-1+1)>0.2 & (min.effects.abovemass*-1+1)<=0.3))
                   , max.20_30=length(which((max.effects.abovemass*-1+1)>0.2 & (max.effects.abovemass*-1+1)<=0.3))
                   , mean.30_40=length(which((mean.effects.abovemass*-1+1)>0.3 & (mean.effects.abovemass*-1+1)<=0.4))
                   , min.30_40=length(which((min.effects.abovemass*-1+1)>0.3 & (min.effects.abovemass*-1+1)<=0.4))
                   , max.30_40=length(which((max.effects.abovemass*-1+1)>0.3 & (max.effects.abovemass*-1+1)<=0.4))
                   , mean.40_50=length(which((mean.effects.abovemass*-1+1)>0.4 & (mean.effects.abovemass*-1+1)<=0.5))
                   , min.40_50=length(which((min.effects.abovemass*-1+1)>0.4 & (min.effects.abovemass*-1+1)<=0.5))
                   , max.40_50=length(which((max.effects.abovemass*-1+1)>0.4 & (max.effects.abovemass*-1+1)<=0.5))
                   , mean.50=length(which((mean.effects.abovemass*-1+1)>0.5))
                   , min.50=length(which((min.effects.abovemass*-1+1)>0.5))
                   , max.50=length(which((max.effects.abovemass*-1+1)>0.5))), by=.(scenario, year)]
  colnames(abovemass) <- c("Application rate", colnames(abovemass)[-1])
  
  shannon<-effect.timestep.GRD[, .(mean.10=length(which((mean.effects.shannon*-1+1)>=0 & (mean.effects.shannon*-1+1)<=0.1))
              , min.10=length(which((min.effects.shannon*-1+1)>=0 & (min.effects.shannon*-1+1)<=0.1))
              , max.10=length(which((max.effects.shannon*-1+1)>=0 & (max.effects.shannon*-1+1)<=0.1))
              , mean.10_20=length(which((mean.effects.shannon*-1+1)>0.1 & (mean.effects.shannon*-1+1)<=0.2))
              , min.10_20=length(which((min.effects.shannon*-1+1)>0.1 & (min.effects.shannon*-1+1)<=0.2))
              , max.10_20=length(which((max.effects.shannon*-1+1)>0.1 & (max.effects.shannon*-1+1)<=0.2))
              , mean.20_30=length(which((mean.effects.shannon*-1+1)>0.2 & (mean.effects.shannon*-1+1)<=0.3))
              , min.20_30=length(which((min.effects.shannon*-1+1)>0.2 & (min.effects.shannon*-1+1)<=0.3))
              , max.20_30=length(which((max.effects.shannon*-1+1)>0.2 & (max.effects.shannon*-1+1)<=0.3))
              , mean.30_40=length(which((mean.effects.shannon*-1+1)>0.3 & (mean.effects.shannon*-1+1)<=0.4))
              , min.30_40=length(which((min.effects.shannon*-1+1)>0.3 & (min.effects.shannon*-1+1)<=0.4))
              , max.30_40=length(which((max.effects.shannon*-1+1)>0.3 & (max.effects.shannon*-1+1)<=0.4))
              , mean.40_50=length(which((mean.effects.shannon*-1+1)>0.4 & (mean.effects.shannon*-1+1)<=0.5))
              , min.40_50=length(which((min.effects.shannon*-1+1)>0.4 & (min.effects.shannon*-1+1)<=0.5))
              , max.40_50=length(which((max.effects.shannon*-1+1)>0.4 & (max.effects.shannon*-1+1)<=0.5))
              , mean.50=length(which((mean.effects.shannon*-1+1)>0.5))
              , min.50=length(which((min.effects.shannon*-1+1)>0.5))
              , max.50=length(which((max.effects.shannon*-1+1)>0.5))), by=.(scenario, year)]
  colnames(shannon) <- c("Application rate", colnames(shannon)[-1])
  
  eveness<-effect.timestep.GRD[, .(mean.10=length(which((mean.effects.eveness*-1+1)>=0 & (mean.effects.eveness*-1+1)<=0.1))
              , min.10=length(which((min.effects.eveness*-1+1)>=0 & (min.effects.eveness*-1+1)<=0.1))
              , max.10=length(which((max.effects.eveness*-1+1)>=0 & (max.effects.eveness*-1+1)<=0.1))
              , mean.10_20=length(which((mean.effects.eveness*-1+1)>0.1 & (mean.effects.eveness*-1+1)<=0.2))
              , min.10_20=length(which((min.effects.eveness*-1+1)>0.1 & (min.effects.eveness*-1+1)<=0.2))
              , max.10_20=length(which((max.effects.eveness*-1+1)>0.1 & (max.effects.eveness*-1+1)<=0.2))
              , mean.20_30=length(which((mean.effects.eveness*-1+1)>0.2 & (mean.effects.eveness*-1+1)<=0.3))
              , min.20_30=length(which((min.effects.eveness*-1+1)>0.2 & (min.effects.eveness*-1+1)<=0.3))
              , max.20_30=length(which((max.effects.eveness*-1+1)>0.2 & (max.effects.eveness*-1+1)<=0.3))
              , mean.30_40=length(which((mean.effects.eveness*-1+1)>0.3 & (mean.effects.eveness*-1+1)<=0.4))
              , min.30_40=length(which((min.effects.eveness*-1+1)>0.3 & (min.effects.eveness*-1+1)<=0.4))
              , max.30_40=length(which((max.effects.eveness*-1+1)>0.3 & (max.effects.eveness*-1+1)<=0.4))
              , mean.40_50=length(which((mean.effects.eveness*-1+1)>0.4 & (mean.effects.eveness*-1+1)<=0.5))
              , min.40_50=length(which((min.effects.eveness*-1+1)>0.4 & (min.effects.eveness*-1+1)<=0.5))
              , max.40_50=length(which((max.effects.eveness*-1+1)>0.4 & (max.effects.eveness*-1+1)<=0.5))
              , mean.50=length(which((mean.effects.eveness*-1+1)>0.5))
              , min.50=length(which((min.effects.eveness*-1+1)>0.5))
              , max.50=length(which((max.effects.eveness*-1+1)>0.5))), by=.(scenario, year)]
  colnames(eveness) <- c("Application rate", colnames(eveness)[-1])
  
  simpson<-effect.timestep.GRD[, .(mean.10=length(which((mean.effects.simpson*-1+1)>=0 & (mean.effects.simpson*-1+1)<=0.1))
              , min.10=length(which((min.effects.simpson*-1+1)>=0 & (min.effects.simpson*-1+1)<=0.1))
              , max.10=length(which((max.effects.simpson*-1+1)>=0 & (max.effects.simpson*-1+1)<=0.1))
              , mean.10_20=length(which((mean.effects.simpson*-1+1)>0.1 & (mean.effects.simpson*-1+1)<=0.2))
              , min.10_20=length(which((min.effects.simpson*-1+1)>0.1 & (min.effects.simpson*-1+1)<=0.2))
              , max.10_20=length(which((max.effects.simpson*-1+1)>0.1 & (max.effects.simpson*-1+1)<=0.2))
              , mean.20_30=length(which((mean.effects.simpson*-1+1)>0.2 & (mean.effects.simpson*-1+1)<=0.3))
              , min.20_30=length(which((min.effects.simpson*-1+1)>0.2 & (min.effects.simpson*-1+1)<=0.3))
              , max.20_30=length(which((max.effects.simpson*-1+1)>0.2 & (max.effects.simpson*-1+1)<=0.3))
              , mean.30_40=length(which((mean.effects.simpson*-1+1)>0.3 & (mean.effects.simpson*-1+1)<=0.4))
              , min.30_40=length(which((min.effects.simpson*-1+1)>0.3 & (min.effects.simpson*-1+1)<=0.4))
              , max.30_40=length(which((max.effects.simpson*-1+1)>0.3 & (max.effects.simpson*-1+1)<=0.4))
              , mean.40_50=length(which((mean.effects.simpson*-1+1)>0.4 & (mean.effects.simpson*-1+1)<=0.5))
              , min.40_50=length(which((min.effects.simpson*-1+1)>0.4 & (min.effects.simpson*-1+1)<=0.5))
              , max.40_50=length(which((max.effects.simpson*-1+1)>0.4 & (max.effects.simpson*-1+1)<=0.5))
              , mean.50=length(which((mean.effects.simpson*-1+1)>0.5))
              , min.50=length(which((min.effects.simpson*-1+1)>0.5))
              , max.50=length(which((max.effects.simpson*-1+1)>0.5))), by=.(scenario, year)]
  colnames(simpson) <- c("Application rate", colnames(simpson)[-1])
  
  simpsoninv<-effect.timestep.GRD[, .(mean.10=length(which((mean.effects.simpsoninv*-1+1)>=0 & (mean.effects.simpsoninv*-1+1)<=0.1))
              , min.10=length(which((min.effects.simpsoninv*-1+1)>=0 & (min.effects.simpsoninv*-1+1)<=0.1))
              , max.10=length(which((max.effects.simpsoninv*-1+1)>=0 & (max.effects.simpsoninv*-1+1)<=0.1))
              , mean.10_20=length(which((mean.effects.simpsoninv*-1+1)>0.1 & (mean.effects.simpsoninv*-1+1)<=0.2))
              , min.10_20=length(which((min.effects.simpsoninv*-1+1)>0.1 & (min.effects.simpsoninv*-1+1)<=0.2))
              , max.10_20=length(which((max.effects.simpsoninv*-1+1)>0.1 & (max.effects.simpsoninv*-1+1)<=0.2))
              , mean.20_30=length(which((mean.effects.simpsoninv*-1+1)>0.2 & (mean.effects.simpsoninv*-1+1)<=0.3))
              , min.20_30=length(which((min.effects.simpsoninv*-1+1)>0.2 & (min.effects.simpsoninv*-1+1)<=0.3))
              , max.20_30=length(which((max.effects.simpsoninv*-1+1)>0.2 & (max.effects.simpsoninv*-1+1)<=0.3))
              , mean.30_40=length(which((mean.effects.simpsoninv*-1+1)>0.3 & (mean.effects.simpsoninv*-1+1)<=0.4))
              , min.30_40=length(which((min.effects.simpsoninv*-1+1)>0.3 & (min.effects.simpsoninv*-1+1)<=0.4))
              , max.30_40=length(which((max.effects.simpsoninv*-1+1)>0.3 & (max.effects.simpsoninv*-1+1)<=0.4))
              , mean.40_50=length(which((mean.effects.simpsoninv*-1+1)>0.4 & (mean.effects.simpsoninv*-1+1)<=0.5))
              , min.40_50=length(which((min.effects.simpsoninv*-1+1)>0.4 & (min.effects.simpsoninv*-1+1)<=0.5))
              , max.40_50=length(which((max.effects.simpsoninv*-1+1)>0.4 & (max.effects.simpsoninv*-1+1)<=0.5))
              , mean.50=length(which((mean.effects.simpsoninv*-1+1)>0.5))
              , min.50=length(which((min.effects.simpsoninv*-1+1)>0.5))
              , max.50=length(which((max.effects.simpsoninv*-1+1)>0.5))), by=.(scenario, year)]
  colnames(simpsoninv) <- c("Application rate", colnames(simpsoninv)[-1])
  
  fwrite(NPFT, "NPFT_GRD.txt", sep="\t")
  fwrite(Inds, "Inds_GRD.txt", sep="\t")
  fwrite(abovemass, "shootmass_GRD.txt", sep="\t")
  fwrite(eveness, "eveness_GRD.txt", sep="\t")
  fwrite(shannon, "shannon_GRD.txt", sep="\t")
  fwrite(simpson, "simpson_GRD.txt", sep="\t")
  fwrite(simpsoninv, "simpsoninv_GRD.txt", sep="\t")
  rm(results.GRD, effect.timestep.GRD, effect.year.GRD, Inds, NPFT, abovemass, shannon, simpson, eveness, simpsoninv)
  gc()
}

Results <- function(){
  ##################################################
  ### Show Simulation Specifics Button
  ##################################################
  ShowSettingsButton <-gtkButton('Show Simulation Settings')
  ShowSettingsButton$setTooltipText('Shows the detailed settings of the current simulation or project')
  ShowSettingsProject <- function(button){
    load(file = "HerbicideSettings/SimulationSettings.Rdata")
    variables <- ls(SaveEnvironment)
    variables <- variables[!(variables %in% c("origFiles", "origWD", "GUIopen", "PFTtoSpecies", "IBCcommunityFile", "IBCloadedSettings",
                                              "IBCAppRateScenarios", "IBCScenarios", "IBCApprates",
                                              "BiomassEffFile", "EstablishmentEffFile", "SeedlingBiomassEffFile", "SeedNumberEffFile",
                                              "SeedSterilityEffFile", "SurvivalEffFile", "PFTSensitivityFile", "EffectData", "nb_data"))]
    variables <- variables[c(
                                     #Community + Gridsize
                                     6,10,
                                     #resources
                                     3,4,5,
                                     # seed input
                                     15,
                                     # disturbances
                                     7, 9, 16,
                                     #HerbDurations
                                     12,8,13,11,5,17,
                                     #attribute
                                     1,2,18,19,20,21,
                                     #MCs
                                     14)]
    dfSettings <- data.frame()
    for(variable in variables){
      value <- as.character(get(variable, envir=SaveEnvironment))
      if(length(value)==0) value <- NA
      rowtoadd <- data.frame(variable, value)
      colnames(rowtoadd) <- c("variable", "value")
      dfSettings <-rbind(dfSettings, rowtoadd)
    }
    
    store <- rGtkDataFrame(dfSettings)
    view <- gtkTreeView(store)
    nms <- names(dfSettings)
    QT <- sapply(1:ncol(dfSettings), function(i) {
      type <- class(dfSettings[,i])[1]
      view$addColumnWithType(name = nms[i], type, viewCol = i, storeCol = i)
    })
    
    
    cb_settings <- gtkButton("Close Window")
    destroy_settingW <- function(button){
      settingW$destroy()
    }
    gSignalConnect(cb_settings, signal = "clicked", destroy_settingW)
    
    PFTsensitivityButton <- gtkButton('Show PFT sensitivity settings')
    
    show_PFTsensitivityFile <- function(button){
      PFTSensitivityFile <- get("PFTSensitivityFile", envir=SaveEnvironment)
      store_PFT <- rGtkDataFrame(PFTSensitivityFile)
      view_PFT <- gtkTreeView(store_PFT)
      nms_PFT <- names(PFTSensitivityFile)
      QT <- sapply(1:ncol(PFTSensitivityFile), function(i) {
        type <- class(PFTSensitivityFile[,i])[1]
        view_PFT$addColumnWithType(name = nms_PFT[i], type, viewCol = i, storeCol = i)
      })
      
      cb_PFTsettings <- gtkButton("Close Window")
      
      destroy_PFTsettingW <- function(button){
        PFTsettingW$destroy()
      }
      
      gSignalConnect(cb_PFTsettings, signal = "clicked", destroy_PFTsettingW)
      
      PFTsettingW <- gtkWindow(show=F)
      color <-gdkColorToString('white')
      PFTsettingW$ModifyBg("normal", color)
      PFTSettings <- gtkScrolledWindow()
      PFTSettings['height.request'] <- 400
      PFTSettings['width.request'] <- 200
      PFTSettings$setPolicy("automatic","automatic")
      PFTSettings$add(view_PFT)
      vbox_PFT<-gtkVBoxNew(spacing=10)
      vbox_PFT$packStart(PFTSettings)
      vbox_PFT$packStart(cb_PFTsettings)
      PFTsettingW$add(vbox_PFT)
      PFTsettingW$show()
    }
    
    gSignalConnect(PFTsensitivityButton, signal = "clicked", show_PFTsensitivityFile)
    
    if(!is.null(get("EffectData", envir=SaveEnvironment))){
      
      EffectDataButton <- gtkButton('Show effect intensities')
      
      show_EffectData <- function(button){
        EffectData <- get("EffectData", envir=SaveEnvironment)
        store_EffectData <- rGtkDataFrame(EffectData)
        view_EffectData <- gtkTreeView(store_EffectData)
        nms_EffectData <- names(EffectData)
        QT <- sapply(1:ncol(EffectData), function(i) {
          type <- class(EffectData[,i])[1]
          view_EffectData$addColumnWithType(name = nms_EffectData[i], type, viewCol = i, storeCol = i)
        })
        
        cb_EffectData <- gtkButton("Close Window")
        
        destroy_EffectDataW <- function(button){
          EffectDataW$destroy()
        }
        
        gSignalConnect(cb_EffectData, signal = "clicked", destroy_EffectDataW)
        
        EffectDataW <- gtkWindow(show=F)
        color <-gdkColorToString('white')
        EffectDataW$ModifyBg("normal", color)
        EffectData_SW <- gtkScrolledWindow()
        EffectData_SW['width.request'] <- 400
        EffectData_SW['height.request'] <- 200
        EffectData_SW$setPolicy("automatic","automatic")
        EffectData_SW$add(view_EffectData)
        vbox_EffectData<-gtkVBoxNew(spacing=10)
        vbox_EffectData$packStart(EffectData_SW)
        vbox_EffectData$packStart(cb_EffectData)
        EffectDataW$add(vbox_EffectData)
        EffectDataW$show()
      }
      
      gSignalConnect(EffectDataButton, signal = "clicked", show_EffectData)
    }
    
    settingW <- gtkWindow(show=F)
    color <-gdkColorToString('white')
    settingW$ModifyBg("normal", color)
    Settings <- gtkScrolledWindow()
    Settings['height.request'] <- 400
    Settings['width.request'] <- 200
    Settings$setPolicy("automatic","automatic")
    Settings$add(view)
    vbox<-gtkVBoxNew(spacing=10)
    vbox$packStart(Settings)
    vbox$packStart(PFTsensitivityButton)
    if(exists("EffectDataButton")){
      vbox$packStart(EffectDataButton)
    }
    vbox$packStart(cb_settings)
    settingW$add(vbox)
    settingW$show()
    
  }
  
  gSignalConnect(ShowSettingsButton, signal = "clicked", ShowSettingsProject)  
  ##################################################
  ### Title
  ################################################## 
  vbox1 <- gtkVBoxNew()
  # vbox1$setBorderWidth(10)
  label_title <- gtkLabel()
  label_title$setMarkup('<span weight=\"bold\" size=\"x-large\">IBC-grass simulation results</span>')
  hboxinvbox_title <- gtkHBoxNew()
  hboxinvbox_title$packStart(label_title, padding=5)
  hboxinvbox_title$packStart(ShowSettingsButton, padding=5)
  vbox1$packStart(hboxinvbox_title, padding=5)
  ##################################################
  ### Preparations
  ################################################## 
  effect.timestep.PFT <- read.table("effect.timestep.PFT.txt", sep="\t", header=T)
  # potential years
  years <- levels(factor(effect.timestep.PFT$year))
  # potential PFTs
  PFTs <- levels(factor(effect.timestep.PFT$PFT))
  # potential variables
  # PFT level
  variables.PFT <- c("Population size", "Shoot mass", "Cover")
  # GRD level
  variables.GRD <- c("Number of PFTs", "Number of plant individuals", "Shoot mass", "Diversity" )
  ###################################################
  ### chunk number 3: AddColumnWithType
  ###################################################
  #line 58 "ex-RGtk2-rGtkDataFrame.Rnw"
  gtkTreeViewAddColumnWithType <-
    function(view,
             name="",
             type=c("character","factor", "integer", "numeric"),
             viewCol,                     # 1-based column of view
             storeCol                     # 1-based column for rGtkDataFrame
    ) {
      
      type = match.arg(type)
      
      ## define the cell renderer
      cr <- #switch(type,
                   gtkCellRendererText()#, #if not factor --> only Text
      #             "factor" = gtkCellRendererCombo() # if type=factor --> add a combo box
      #)
      
      ## the new column we will add
      vc <- gtkTreeViewColumn()
      vc$packStart(cr, TRUE)
      vc$setTitle(name)
      vc$setResizable(TRUE); vc$setClickable(TRUE)
      view$InsertColumn(vc, viewCol - 1)  # viewCol is 1-based
      
      ## add attributes
      switch(type,
             "logical" =  vc$addAttribute(cr, "active",storeCol - 1), # only if logical
             vc$addAttribute(cr, "text",storeCol - 1) # everything else
      )
      if(type == "numeric") cr['xalign'] <- 1 # only if numeric
      
      ## set editable/activatable property
      switch(type,
             "logical" = cr["activatable"] <- TRUE, # only if logical
             cr["editable"] <- TRUE) # everything else
      
      
      
      ## connect callback to edited/toggled signal
      QT <- gSignalConnect(cr, signal =
                             if(type != "logical") "edited" else "toggled",
                           f = editCallBack, 
                           data = list(view=view,type=type,column=storeCol))
    }
  ###################################################
  ### chunk number 2: callBackEdit
  ###################################################
  #line 17 "ex-RGtk2-rGtkDataFrame.Rnw"
  editCallBack <- function(cell, path, arg3, ...) {
    if(nargs() == 3) {
      userData <- arg3; newValue <- NA    # no newValue (toggle)
    } else {
      newValue <- arg3; userData = ..1    # ..1 is first component of ...
    }
    rGtkStore <- userData$view$getModel()
    i <- as.numeric(path) + 1
    j <- userData$column
    newValue <- try(switch(userData$type,
                           "integer" = as.integer(as.numeric(newValue)),
                           "character" = as.character(newValue),
                           "numeric" = as.numeric(newValue),
                           "factor"  = as.character(newValue),
                           "logical" =  !as.logical(rGtkStore[i,j])),
                    silent=TRUE)
    
    if(inherits(newValue,"try-error")) {
      sprintf("Failed to coerce new value to type %s",userData$type)
      return(FALSE)
    }
    
   
    
    rGtkStore[i,j] <- newValue            # assign value
    return(FALSE)
  }
  
  
  ##################################################
  ### Show graphics Pop function
  ##################################################
  ShowGraphicsPopFct <- function(button){
    # clean input of outputPopGraphics
    if(length(outputPopGraphics$getChildren())!=0) outputPopGraphics$remove(outputPopGraphics$getChildren()[[1]])
    #
    GraphicsPop<-gtkNotebook()
    # get years
    start_year <- StartYearSliderPop$getValue()
    end_year <- EndYearSliderPop$getValue()
    if(end_year>start_year){
      years.toplot <- c(start_year:end_year)
      # get the list of PFTs that should be plotted
      PFT.toplot<-c()
      for(i in 1:length(PFTs)){
        place <- i
        if (vboxPFTs[[place]]$getActive()) PFT.toplot<-c(PFT.toplot,PFTs[i])
      }
      if (length(PFT.toplot)!=0){
        # get the variables
        # determines how many notebooks in this current one
        variable<-c()
        for(i in 1:length(variables.PFT)){
          place <- i
          if (vboxVariablesPop[[place]]$getActive()) variable<-c(variable,variables.PFT[i])
        }
          if (length(variable)!=0){
            # read in file
            # if short-term --> effect.timestep.PFT
            if (length(years.toplot) <= 5) {
              to.plot<-read.table("effect.timestep.PFT.txt", header=T, sep="\t")
              
              to.plot <- to.plot[which(to.plot$PFT %in% PFT.toplot),]
              to.plot <- to.plot[which(to.plot$year %in% years.toplot),]
              
              if ("Population size" %in% variable) {
                # initialize frame for Popsize graphic
                PopSize <- gtkFrame()
                vboxPopSize1<-gtkVBox()
                vboxPopSize1$setBorderWidth(5)
                vboxPopSize<-gtkVBox()
                vboxPopSize$setBorderWidth(5)
                
                png("PopSizePlot.png", width=350, height=350)
                PopSizeP <- ggplot(data=to.plot)+
                  theme_tufte(base_family = "sans")+
                  geom_ribbon(data=to.plot[which(to.plot$scenario==0),],aes(x=Time, ymin=min.effects.Inds, ymax=max.effects.Inds, fill=factor(scenario)))+
                  geom_line(data=to.plot[which(to.plot$scenario!=0),],aes(x=Time, y=mean.effects.Inds, color=factor(scenario)))+
                  geom_line(data=to.plot[which(to.plot$scenario==0),],aes(x=Time, y=mean.effects.Inds), color='black', linetype='dotted')+
                  facet_wrap(~factor(PFT))+
                  scale_fill_manual(breaks=c(0), values=c("grey")) +
                  scale_colour_colorblind() +
                  scale_x_continuous(breaks = seq(min(to.plot$Time), max(to.plot$Time), 30),
                                     labels=seq(min(to.plot$year), max(to.plot$year), 1))+
                  guides(fill=guide_legend(title="", order=2),color=guide_legend(title="Application rate", order=1)) +
                  theme(axis.line = element_line(color = 'black')) +
                  ylab("Effect in population size") +
                  xlab("Year")
                print(PopSizeP)
                dev.off()
                PopPlot<-gtkImageNewFromFile("PopSizePlot.png")
                
                label_PopPlot<-gtkLabel('
                                        Mean effect in population size for the selected PFTs over the selected period. 
                                        The mean effects per week are shown in solid lines. The black dotted line and the grey ribbon show 
                                        the mean effect and the 2.5th and 97.5th percentile of the effects in the control simulations.')
                
                vboxPopSize1$packStart(PopPlot)
                vboxPopSize1$packStart(label_PopPlot)
                
                saveButton <-gtkButton('Save')
                saveButton$setTooltipText('Save the current graphic (without description) at a specified location.')
                SaveDialog <- function(button){
                  dialog <- gtkFileChooserDialog ( title = "Save a file" ,
                                                   parent = w , action = "save" ,
                                                   "gtk-ok" , GtkResponseType [ "ok" ] ,
                                                   "gtk-cancel" , GtkResponseType [ "cancel" ] ,
                                                   show = FALSE )
                  color <-gdkColorToString('white')
                  dialog$ModifyBg("normal", color)
                  dialog$setCurrentName ("PopSize.pdf")
                  gSignalConnect ( dialog , "response" ,
                                   f = function ( dialog , response , data ) {
                                     if ( response == GtkResponseType [ "ok" ] ) {
                                       filename <- dialog$getFilename ( )
                                       dev <- unlist(strsplit(filename, "[.]"))[2]
                                       dev.ok <- c("ps", "tex", "pdf", "jpeg", "tiff", "png", "bmp", "wmf")
                                       if (dev %in% dev.ok){
                                         ggsave(filename, PopSizeP)
                                       } else {
                                         dialog_tmp <- gtkMessageDialog(parent=dialog,
                                                                    flags = "destroy-with-parent",
                                                                    type="question" ,
                                                                    buttons="ok" ,
                                                                    "Please ensure that you save the figure as 
'ps', 'tex', 'pdf', 'jpeg', 'tiff', 'png', 'bmp'or 'wmf'.")
                                         color <-gdkColorToString('white')
                                         dialog_tmp$ModifyBg("normal", color)
                                         gSignalConnect (dialog_tmp, "response", function(dialog_tmp, response, user.data){ dialog_tmp$Destroy()})
                                       }
                                     }
                                     dialog$destroy ( )
                                   } )
                  
                  dialog$run()
                }
                
                gSignalConnect(saveButton, signal = "clicked", SaveDialog)
                
                vboxPopSize$packStart(vboxPopSize1)
                vboxPopSize$packStart(saveButton, fill=F)
                
                PopSize$add(vboxPopSize)
                
                # add popsize graphic frame to notebook
                gtkNotebookAppendPage(GraphicsPop, PopSize, tab.label=gtkLabel("Population size"))
              }
              
              if ("Shoot mass" %in% variable) {
                # initialize frame for Shootmass graphic
                Shootmass <- gtkFrame()
                vboxShootmass1 <- gtkVBox()
                vboxShootmass1$setBorderWidth(5)
                vboxShootmass <- gtkVBox()
                vboxShootmass$setBorderWidth(5)
                
                png("ShootmassPlot.png", width=350, height=350)
                ShootmassP <-  ggplot(data=to.plot)+
                  theme_tufte(base_family = "sans")+
                  geom_ribbon(data=to.plot[which(to.plot$scenario==0),],aes(x=Time, ymin=min.effects.shootmass, ymax=max.effects.shootmass, fill=factor(scenario)))+
                  geom_line(data=to.plot[which(to.plot$scenario!=0),],aes(x=Time, y=mean.effects.shootmass, color=factor(scenario)))+
                  geom_line(data=to.plot[which(to.plot$scenario==0),],aes(x=Time, y=mean.effects.shootmass), color='black', linetype='dotted')+
                  facet_wrap(~factor(PFT))+
                  scale_fill_manual(breaks=c(0), values=c("grey")) +
                  scale_colour_colorblind() +
                  scale_x_continuous(breaks = seq(min(to.plot$Time), max(to.plot$Time), 30),
                                     labels=seq(min(to.plot$year), max(to.plot$year), 1))+
                  guides(fill=guide_legend(title="", order=2),color=guide_legend(title="Application rate", order=1)) +
                  theme(axis.line = element_line(color = 'black')) +
                  ylab("Effect in shoot mass") +
                  xlab("Year")
                print(ShootmassP)
                dev.off()
                ShootmassPlot<-gtkImageNewFromFile("ShootmassPlot.png")
                
                label_ShootmassPlot<-gtkLabel('
                                              Mean effect in shoot mass for the selected PFTs. 
                                              The mean effects are shown in solid lines. The black dotted line and the grey ribbon show 
                                              the mean effect and the 2.5th and 97.5th percentile of the effects in the control simulations.')
                
                vboxShootmass1$packStart(ShootmassPlot)
                vboxShootmass1$packStart(label_ShootmassPlot)
                
                saveButton <-gtkButton('Save')
                saveButton$setTooltipText('Save the current graphic (without description) at a specified location.')
                SaveDialog <- function(button){
                  dialog <- gtkFileChooserDialog ( title = "Save a file" ,
                                                   parent = w , action = "save" ,
                                                   "gtk-ok" , GtkResponseType [ "ok" ] ,
                                                   "gtk-cancel" , GtkResponseType [ "cancel" ] ,
                                                   show = FALSE )
                  color <-gdkColorToString('white')
                  dialog$ModifyBg("normal", color)
                  dialog$setCurrentName ("Shootmass.pdf")
                  gSignalConnect ( dialog , "response" ,
                                   f = function ( dialog , response , data ) {
                                     if ( response == GtkResponseType [ "ok" ] ) {
                                       filename <- dialog$getFilename ( )
                                       dev <- unlist(strsplit(filename, "[.]"))[2]
                                       dev.ok <- c("ps", "tex", "pdf", "jpeg", "tiff", "png", "bmp", "wmf")
                                       if (dev %in% dev.ok){
                                         ggsave(filename, ShootmassP)
                                       } else {
                                         dialog_tmp <- gtkMessageDialog(parent=dialog,
                                                                        flags = "destroy-with-parent",
                                                                        type="question" ,
                                                                        buttons="ok" ,
                                                                        "Please ensure that you save the figure as 
'ps', 'tex', 'pdf', 'jpeg', 'tiff', 'png', 'bmp'or 'wmf'.")
                                         color <-gdkColorToString('white')
                                         dialog_tmp$ModifyBg("normal", color)
                                         gSignalConnect (dialog_tmp, "response", function(dialog_tmp, response, user.data){ dialog_tmp$Destroy()})
                                         
                                       }
                                       
                                     }
                                     dialog$destroy ( )
                                   } )
                  
                  dialog$run()
                }
                
                gSignalConnect(saveButton, signal = "clicked", SaveDialog)
                
                vboxShootmass$packStart(vboxShootmass1)
                vboxShootmass$packStart(saveButton, fill=F)
                
                
                Shootmass$add(vboxShootmass)
                # add shootmass graphic frame to notebook
                gtkNotebookAppendPage(GraphicsPop, Shootmass, tab.label=gtkLabel("Shoot mass"))
              }
              
              if ("Cover" %in% variable) {
                # initialize frame for Cover graphic
                Cover <- gtkFrame()
                vboxCover1<-gtkVBox()
                vboxCover1$setBorderWidth(5)
                vboxCover<-gtkVBox()
                vboxCover$setBorderWidth(5)
                
                png("CoverPlot.png", width=350, height=350)
                CoverP <-  ggplot(data=to.plot)+
                  theme_tufte(base_family = "sans")+
                  geom_ribbon(data=to.plot[which(to.plot$scenario==0),],aes(x=Time, ymin=min.effects.cover, ymax=max.effects.cover, fill=factor(scenario)))+
                  geom_line(data=to.plot[which(to.plot$scenario!=0),],aes(x=Time, y=mean.effects.cover, color=factor(scenario)))+
                  geom_line(data=to.plot[which(to.plot$scenario==0),],aes(x=Time, y=mean.effects.cover), color='black', linetype='dotted')+
                  facet_wrap(~factor(PFT))+
                  scale_fill_manual(breaks=c(0), values=c("grey")) +
                  scale_colour_colorblind() +
                  scale_x_continuous(breaks = seq(min(to.plot$Time), max(to.plot$Time), 30),
                                     labels=seq(min(to.plot$year), max(to.plot$year), 1))+
                  guides(fill=guide_legend(title="", order=2),color=guide_legend(title="Application rate", order=1)) +
                  theme(axis.line = element_line(color = 'black')) +
                  ylab("Effect in cover") +
                  xlab("Year")
                print(CoverP)
                dev.off()
                CoverPlot<-gtkImageNewFromFile("CoverPlot.png")
                
                label_CoverPlot<-gtkLabel('
                                          Mean effect in cover for the selected PFTs over the selected period. 
                                          The mean effects per week are shown in solid lines. The black dotted line and the grey ribbon show 
                                          the mean effect and the 2.5th and 97.5th percentile of the effects in the control simulations.')
                
                vboxCover1$packStart(CoverPlot)
                vboxCover1$packStart(label_CoverPlot)
                
                saveButton <-gtkButton('Save')
                saveButton$setTooltipText('Save the current graphic (without description) at a specified location.')
                SaveDialog <- function(button){
                  dialog <- gtkFileChooserDialog ( title = "Save a file" ,
                                                   parent = w , action = "save" ,
                                                   "gtk-ok" , GtkResponseType [ "ok" ] ,
                                                   "gtk-cancel" , GtkResponseType [ "cancel" ] ,
                                                   show = FALSE )
                  color <-gdkColorToString('white')
                  dialog$ModifyBg("normal", color)
                  dialog$setCurrentName ("Cover.pdf")
                  gSignalConnect ( dialog , "response" ,
                                   f = function ( dialog , response , data ) {
                                     if ( response == GtkResponseType [ "ok" ] ) {
                                       filename <- dialog$getFilename ( )
                                       dev <- unlist(strsplit(filename, "[.]"))[2]
                                       dev.ok <- c("ps", "tex", "pdf", "jpeg", "tiff", "png", "bmp", "wmf")
                                       if (dev %in% dev.ok){
                                         ggsave(filename, CoverP)
                                       } else {
                                         dialog_tmp <- gtkMessageDialog(parent=dialog,
                                                                        flags = "destroy-with-parent",
                                                                        type="question" ,
                                                                        buttons="ok" ,
                                                                        "Please ensure that you save the figure as 
'ps', 'tex', 'pdf', 'jpeg', 'tiff', 'png', 'bmp'or 'wmf'.")
                                         color <-gdkColorToString('white')
                                         dialog_tmp$ModifyBg("normal", color)
                                         gSignalConnect (dialog_tmp, "response", function(dialog_tmp, response, user.data){ dialog_tmp$Destroy()})
                                         
                                       }
                                       
                                     }
                                     dialog$destroy ( )
                                   } )
                  
                  dialog$run()
                }
                
                gSignalConnect(saveButton, signal = "clicked", SaveDialog)
                
                vboxCover$packStart(vboxCover1)
                vboxCover$packStart(saveButton, fill=F)
                
                Cover$add(vboxCover)
                # add cover graphic frame to notebook
                gtkNotebookAppendPage(GraphicsPop, Cover, tab.label=gtkLabel("Cover"))
              }
              
              outputPopGraphics$add(GraphicsPop)
            }
            # if long-term --> effect.year.PFT
            if (length(years.toplot) > 5) {
              to.plot<-read.table("effect.year.PFT.txt", header=T, sep="\t")
              
              to.plot <- to.plot[which(to.plot$PFT %in% PFT.toplot),]
              to.plot <- to.plot[which(to.plot$year %in% years.toplot),]
              
              if ("Population size" %in% variable) {
                # initialize frame for Popsize graphic
                PopSize <- gtkFrame()
                vboxPopSize1<-gtkVBox()
                vboxPopSize1$setBorderWidth(5)
                vboxPopSize<-gtkVBox()
                vboxPopSize$setBorderWidth(5)
                
                png("PopSizePlot.png", width=350, height=350)
                PopSizeP <-  ggplot(data=to.plot)+
                  theme_tufte(base_family = "sans")+
                  geom_ribbon(data=to.plot[which(to.plot$scenario==0),],aes(x=year, ymin=min.effects.Inds, ymax=max.effects.Inds, fill=factor(scenario)))+
                  geom_line(data=to.plot[which(to.plot$scenario!=0),],aes(x=year, y=mean.effects.Inds, color=factor(scenario)))+
                  geom_line(data=to.plot[which(to.plot$scenario==0),],aes(x=year, y=mean.effects.Inds), color='black', linetype='dotted')+
                  facet_wrap(~factor(PFT))+
                  scale_fill_manual(breaks=c(0), values=c("grey")) +
                  scale_colour_colorblind() +
                  # scale_x_continuous(breaks = seq(min(to.plot$Time), max(to.plot$Time), 30),
                  #                    labels=seq(min(to.plot$year), max(to.plot$year), 1))+
                  guides(fill=guide_legend(title="", order=2),color=guide_legend(title="Application rate", order=1)) +
                  theme(axis.line = element_line(color = 'black')) +
                  ylab("Effect in population size") +
                  xlab("Year")
                print(PopSizeP)
                dev.off()
                PopPlot<-gtkImageNewFromFile("PopSizePlot.png")
                
                label_PopPlot<-gtkLabel('
                                        Mean effect in population size for the selected PFTs over the selected period. 
                                        The mean effects per year are shown in solid lines. The black dotted line and the grey ribbon show 
                                        the mean effect and the 2.5th and 97.5th percentile of the effects in the control simulations.')
                
                vboxPopSize1$packStart(PopPlot)
                vboxPopSize1$packStart(label_PopPlot)
                
                saveButton <-gtkButton('Save')
                saveButton$setTooltipText('Save the current graphic (without description) at a specified location.')
                SaveDialog <- function(button){
                  dialog <- gtkFileChooserDialog ( title = "Save a file" ,
                                                   parent = w , action = "save" ,
                                                   "gtk-ok" , GtkResponseType [ "ok" ] ,
                                                   "gtk-cancel" , GtkResponseType [ "cancel" ] ,
                                                   show = FALSE )
                  color <-gdkColorToString('white')
                  dialog$ModifyBg("normal", color)
                  dialog$setCurrentName ("PopSize.pdf")
                  gSignalConnect ( dialog , "response" ,
                                   f = function ( dialog , response , data ) {
                                     if ( response == GtkResponseType [ "ok" ] ) {
                                       filename <- dialog$getFilename ( )
                                       dev <- unlist(strsplit(filename, "[.]"))[2]
                                       dev.ok <- c("ps", "tex", "pdf", "jpeg", "tiff", "png", "bmp", "wmf")
                                       if (dev %in% dev.ok){
                                         ggsave(filename, PopSizeP)
                                       } else {
                                         dialog_tmp <- gtkMessageDialog(parent=dialog,
                                                                        flags = "destroy-with-parent",
                                                                        type="question" ,
                                                                        buttons="ok" ,
                                                                        "Please ensure that you save the figure as 
'ps', 'tex', 'pdf', 'jpeg', 'tiff', 'png', 'bmp'or 'wmf'.")
                                         color <-gdkColorToString('white')
                                         dialog_tmp$ModifyBg("normal", color)
                                         gSignalConnect (dialog_tmp, "response", function(dialog_tmp, response, user.data){ dialog_tmp$Destroy()})
                                         
                                       }
                                       
                                     }
                                     dialog$destroy ( )
                                   } )
                  
                  dialog$run()
                }
                
                gSignalConnect(saveButton, signal = "clicked", SaveDialog)
                
                vboxPopSize$packStart(vboxPopSize1)
                vboxPopSize$packStart(saveButton, fill=F)
                
                PopSize$add(vboxPopSize)
                
                # add popsize graphic frame to notebook
                gtkNotebookAppendPage(GraphicsPop, PopSize, tab.label=gtkLabel("Population size"))
              }
              
              if ("Shoot mass" %in% variable) {
                # initialize frame for Shootmass graphic
                Shootmass <- gtkFrame()
                vboxShootmass1 <- gtkVBox()
                vboxShootmass1$setBorderWidth(5)
                vboxShootmass <- gtkVBox()
                vboxShootmass$setBorderWidth(5)
                
                png("ShootmassPlot.png", width=350, height=350)
                ShootmassP <-  ggplot(data=to.plot)+
                  theme_tufte(base_family = "sans")+
                  geom_ribbon(data=to.plot[which(to.plot$scenario==0),],aes(x=year, ymin=min.effects.shootmass, ymax=max.effects.shootmass, fill=factor(scenario)))+
                  geom_line(data=to.plot[which(to.plot$scenario!=0),],aes(x=year, y=mean.effects.shootmass, color=factor(scenario)))+
                  geom_line(data=to.plot[which(to.plot$scenario==0),],aes(x=year, y=mean.effects.shootmass), color='black', linetype='dotted')+
                  facet_wrap(~factor(PFT))+
                  scale_fill_manual(breaks=c(0), values=c("grey")) +
                  scale_colour_colorblind() +
                  # scale_x_continuous(breaks = seq(min(to.plot$Time), max(to.plot$Time), 30),
                  #                    labels=seq(min(to.plot$year), max(to.plot$year), 1))+
                  guides(fill=guide_legend(title="", order=2),color=guide_legend(title="Application rate", order=1)) +
                  theme(axis.line = element_line(color = 'black')) +
                  ylab("Effect in shoot mass") +
                  xlab("Year")
                print(ShootmassP)
                dev.off()
                ShootmassPlot<-gtkImageNewFromFile("ShootmassPlot.png")
                
                label_ShootmassPlot<-gtkLabel('
                                              Mean effect in shoot mass for the selected PFTs over the selected period. 
                                              The mean effects per year are shown in solid lines. The black dotted line and the grey ribbon show 
                                              the mean effect and the 2.5th and 97.5th percentile of the effects in the control simulations.')
                
                vboxShootmass1$packStart(ShootmassPlot)
                vboxShootmass1$packStart(label_ShootmassPlot)
                
                saveButton <-gtkButton('Save')
                saveButton$setTooltipText('Save the current graphic (without description) at a specified location.')
                SaveDialog <- function(button){
                  dialog <- gtkFileChooserDialog ( title = "Save a file" ,
                                                   parent = w , action = "save" ,
                                                   "gtk-ok" , GtkResponseType [ "ok" ] ,
                                                   "gtk-cancel" , GtkResponseType [ "cancel" ] ,
                                                   show = FALSE )
                  color <-gdkColorToString('white')
                  dialog$ModifyBg("normal", color)
                  dialog$setCurrentName ("Shootmass.pdf")
                  gSignalConnect ( dialog , "response" ,
                                   f = function ( dialog , response , data ) {
                                     if ( response == GtkResponseType [ "ok" ] ) {
                                       filename <- dialog$getFilename ( )
                                       dev <- unlist(strsplit(filename, "[.]"))[2]
                                       dev.ok <- c("ps", "tex", "pdf", "jpeg", "tiff", "png", "bmp", "wmf")
                                       if (dev %in% dev.ok){
                                         ggsave(filename, ShootmassP)
                                       } else {
                                         dialog_tmp <- gtkMessageDialog(parent=dialog,
                                                                        flags = "destroy-with-parent",
                                                                        type="question" ,
                                                                        buttons="ok" ,
                                                                        "Please ensure that you save the figure as 
'ps', 'tex', 'pdf', 'jpeg', 'tiff', 'png', 'bmp'or 'wmf'.")
                                         color <-gdkColorToString('white')
                                         dialog_tmp$ModifyBg("normal", color)
                                         gSignalConnect (dialog_tmp, "response", function(dialog_tmp, response, user.data){ dialog_tmp$Destroy()})
                                         
                                       }
                                       
                                     }
                                     dialog$destroy ( )
                                   } )
                  
                  dialog$run()
                }
                
                gSignalConnect(saveButton, signal = "clicked", SaveDialog)
                
                vboxShootmass$packStart(vboxShootmass1)
                vboxShootmass$packStart(saveButton, fill=F)
                
                Shootmass$add(vboxShootmass)
                # add shootmass graphic frame to notebook
                gtkNotebookAppendPage(GraphicsPop, Shootmass, tab.label=gtkLabel("Shoot mass"))
              }
              
              if ("Cover" %in% variable) {
                # initialize frame for Cover graphic
                Cover <- gtkFrame()
                vboxCover1 <- gtkVBox()
                vboxCover1$setBorderWidth(5)
                vboxCover <- gtkVBox()
                vboxCover$setBorderWidth(5)
                
                png("CoverPlot.png", width=350, height=350)
                CoverP <- ggplot(data=to.plot)+
                  theme_tufte(base_family = "sans")+
                  geom_ribbon(data=to.plot[which(to.plot$scenario==0),],aes(x=year, ymin=min.effects.cover, ymax=max.effects.cover, fill=factor(scenario)))+
                  geom_line(data=to.plot[which(to.plot$scenario!=0),],aes(x=year, y=mean.effects.cover, color=factor(scenario)))+
                  geom_line(data=to.plot[which(to.plot$scenario==0),],aes(x=year, y=mean.effects.cover), color='black', linetype='dotted')+
                  facet_wrap(~factor(PFT))+
                  scale_fill_manual(breaks=c(0), values=c("grey")) +
                  scale_colour_colorblind() +
                  guides(fill=guide_legend(title="", order=2),color=guide_legend(title="Application rate", order=1)) +
                  theme(axis.line = element_line(color = 'black')) +
                  ylab("Effect in cover") +
                  xlab("Year")
                print(CoverP)
                dev.off()
                CoverPlot<-gtkImageNewFromFile("CoverPlot.png")
                
                label_CoverPlot<-gtkLabel('
                                      Mean effect in cover for the selected PFTs over the selected period. 
                                      The mean effects per year are shown in solid lines. The black dotted line and the grey ribbon show 
                                      the mean effect and the 2.5th and 97.5th percentile of the effects in the control simulations.')
                
                vboxCover1$packStart(CoverPlot)
                vboxCover1$packStart(label_CoverPlot)
                
                saveButton <-gtkButton('Save')
                saveButton$setTooltipText('Save the current graphic (without description) at a specified location.')
                SaveDialog <- function(button){
                  dialog <- gtkFileChooserDialog ( title = "Save a file" ,
                                                   parent = w , action = "save" ,
                                                   "gtk-ok" , GtkResponseType [ "ok" ] ,
                                                   "gtk-cancel" , GtkResponseType [ "cancel" ] ,
                                                   show = FALSE )
                  color <-gdkColorToString('white')
                  dialog$ModifyBg("normal", color)
                  dialog$setCurrentName ("Cover.pdf")
                  gSignalConnect ( dialog , "response" ,
                                   f = function ( dialog , response , data ) {
                                     if ( response == GtkResponseType [ "ok" ] ) {
                                       filename <- dialog$getFilename ( )
                                       dev <- unlist(strsplit(filename, "[.]"))[2]
                                       dev.ok <- c("ps", "tex", "pdf", "jpeg", "tiff", "png", "bmp", "wmf")
                                       if (dev %in% dev.ok){
                                         ggsave(filename, CoverP)
                                       } else {
                                         dialog_tmp <- gtkMessageDialog(parent=dialog,
                                                                        flags = "destroy-with-parent",
                                                                        type="question" ,
                                                                        buttons="ok" ,
                                                                        "Please ensure that you save the figure as 
'ps', 'tex', 'pdf', 'jpeg', 'tiff', 'png', 'bmp' or 'wmf'.")
                                         color <-gdkColorToString('white')
                                         dialog_tmp$ModifyBg("normal", color)
                                         gSignalConnect (dialog_tmp, "response", function(dialog_tmp, response, user.data){ dialog_tmp$Destroy()})
                                         
                                       }
                                       
                                     }
                                     dialog$destroy ( )
                                   } )
                  
                  dialog$run()
                }
                
                gSignalConnect(saveButton, signal = "clicked", SaveDialog)
                
                vboxCover$packStart(vboxCover1)
                vboxCover$packStart(saveButton, fill=F)
                
                Cover$add(vboxCover)
                # add cover graphic frame to notebook
                gtkNotebookAppendPage(GraphicsPop, Cover, tab.label=gtkLabel("Cover"))
              }
              
              outputPopGraphics$add(GraphicsPop)
            }
            
            ShowGraphicsPop$label<-'Update graphics'
          } else {
            dialog <- gtkMessageDialog(parent=w,
                                       flags = "destroy-with-parent",
                                       type="question" ,
                                       buttons="ok" ,
                                       "Please ensure that you select at least one variable.")
            color <-gdkColorToString('white')
            dialog$ModifyBg("normal", color)
            gSignalConnect (dialog, "response", function(dialog, response, user.data){ dialog$Destroy()})
          }
        } else {
          dialog <- gtkMessageDialog(parent=w,
                                     flags = "destroy-with-parent",
                                     type="question" ,
                                     buttons="ok" ,
                                     "Please ensure that you select at least one PFT.")
          color <-gdkColorToString('white')
          dialog$ModifyBg("normal", color)
          gSignalConnect (dialog, "response", function(dialog, response, user.data){ dialog$Destroy()})
        }
      } else{
        dialog <- gtkMessageDialog(parent=w,
                                   flags = "destroy-with-parent",
                                   type="question" ,
                                   buttons="ok" ,
                                   "Please ensure that the first year you would like to plot is smaller than the last year.")
        color <-gdkColorToString('white')
        dialog$ModifyBg("normal", color)
        gSignalConnect (dialog, "response", function(dialog, response, user.data){ dialog$Destroy()})
      }
    }
  ##################################################
  ### Show graphics Com function
  ##################################################
  ShowGraphicsComFct <- function(button){
    # clean input of outputComGraphics
    if(length(outputComGraphics$getChildren())!=0) outputComGraphics$remove(outputComGraphics$getChildren()[[1]])
    #
    GraphicsCom<-gtkNotebook()
    # get years
    start_year <- StartYearSliderCom$getValue()
    end_year <- EndYearSliderCom$getValue()
    if(end_year>start_year){
       years.toplot <- c(start_year:end_year)
      # get the variables
      # determines how many notebooks in this current one
      variable<-c()
      for(i in 1:length(variables.GRD)){
        place <- i
        if (vboxVariables[[place]]$getActive()) variable<-c(variable,variables.GRD[i])
      }
      if (length(variable)!=0){
        # read in file
        # if short-term --> effect.timestep.PFT
        if (length(years.toplot) <= 5) {
          to.plot<-read.table("effect.timestep.GRD.txt", header=T, sep="\t")
    
          to.plot <- to.plot[which(to.plot$year %in% years.toplot),]
          
          if ("Number of PFTs" %in% variable) {
            # initialize frame for Popsize graphic
            NPFT <- gtkFrame()
            vboxNPFT<-gtkVBox()
            vboxNPFT$setBorderWidth(10)
            vboxNPFT1<-gtkVBox()
            vboxNPFT1$setBorderWidth(10)
            
            png("NPFTPlot.png", width=350, height=350)
            NPFTP <- ggplot(data=to.plot)+
              theme_tufte(base_family = "sans")+
              geom_ribbon(data=to.plot[which(to.plot$scenario==0),],aes(x=Time, ymin=min.effects.NPFT, ymax=max.effects.NPFT, fill=factor(scenario)))+
              geom_line(data=to.plot[which(to.plot$scenario!=0),],aes(x=Time, y=mean.effects.NPFT, color=factor(scenario)))+
              geom_line(data=to.plot[which(to.plot$scenario==0),],aes(x=Time, y=mean.effects.NPFT), color='black', linetype='dotted')+
              scale_fill_manual(breaks=c(0), values=c("grey")) +
              scale_colour_colorblind() +
              scale_x_continuous(breaks = seq(min(to.plot$Time), max(to.plot$Time), 30),
                                 labels=seq(min(to.plot$year), max(to.plot$year), 1))+
              guides(fill=guide_legend(title="", order=2),color=guide_legend(title="Application rate", order=1)) +
              theme(axis.line = element_line(color = 'black')) +
              ylab("Effect in number of PFTs") +
              xlab("Year")
            print(NPFTP)
            dev.off()
            NPFTPlot<-gtkImageNewFromFile("NPFTPlot.png")
            
            label_NPFTPlot<-gtkLabel('
    Mean effect in number of PFTs over the selected period. 
    The mean effects per week are shown in solid lines. The black dotted line and the grey ribbon show 
    the mean effect and the 2.5th and 97.5th percentile of the effects in the control simulations.')
            
            
            vboxNPFT1$packStart(NPFTPlot)
            vboxNPFT1$packStart(label_NPFTPlot)
            
            saveButton <-gtkButton('Save')
            saveButton$setTooltipText('Save the current graphic (without description) at a specified location.')
            SaveDialog <- function(button){
              dialog <- gtkFileChooserDialog ( title = "Save a file" ,
                                               parent = w , action = "save" ,
                                               "gtk-ok" , GtkResponseType [ "ok" ] ,
                                               "gtk-cancel" , GtkResponseType [ "cancel" ] ,
                                               show = FALSE )
              color <-gdkColorToString('white')
              dialog$ModifyBg("normal", color)
              dialog$setCurrentName ("NPFT.pdf")
              gSignalConnect ( dialog , "response" ,
                               f = function ( dialog , response , data ) {
                                 if ( response == GtkResponseType [ "ok" ] ) {
                                   filename <- dialog$getFilename ( )
                                   dev <- unlist(strsplit(filename, "[.]"))[2]
                                   dev.ok <- c("ps", "tex", "pdf", "jpeg", "tiff", "png", "bmp", "wmf")
                                   if (dev %in% dev.ok){
                                     ggsave(filename, NPFTP)
                                   } else {
                                     dialog_tmp <- gtkMessageDialog(parent=dialog,
                                                                    flags = "destroy-with-parent",
                                                                    type="question" ,
                                                                    buttons="ok" ,
                                                                    "Please ensure that you save the figure as 
'ps', 'tex', 'pdf', 'jpeg', 'tiff', 'png', 'bmp'or 'wmf'.")
                                     color <-gdkColorToString('white')
                                     dialog_tmp$ModifyBg("normal", color)
                                     gSignalConnect (dialog_tmp, "response", function(dialog_tmp, response, user.data){ dialog_tmp$Destroy()})
                                     
                                   }
                                   
                                 }
                                 dialog$destroy ( )
                               } )
              
              dialog$run()
            }
            
            gSignalConnect(saveButton, signal = "clicked", SaveDialog)
            
            vboxNPFT$packStart(vboxNPFT1)
            vboxNPFT$packStart(saveButton, fill=F)
            
            NPFT$add(vboxNPFT)
            
            # add popsize graphic frame to notebook
            gtkNotebookAppendPage(GraphicsCom, NPFT, tab.label=gtkLabel("Number of PFTs"))
          }
          
          if ("Number of plant individuals" %in% variable) {
            # initialize frame for Popsize graphic
            Inds <- gtkFrame()
            vboxInds <- gtkVBox()
            vboxInds$setBorderWidth(10)
            vboxInds1 <- gtkVBox()
            vboxInds1$setBorderWidth(10)
            
            png("IndsPlot.png", width=350, height=350)
            IndsP <- ggplot(data=to.plot)+
              theme_tufte(base_family = "sans")+
              geom_ribbon(data=to.plot[which(to.plot$scenario==0),],aes(x=Time, ymin=min.effects.Inds, ymax=max.effects.Inds, fill=factor(scenario)))+
              geom_line(data=to.plot[which(to.plot$scenario!=0),],aes(x=Time, y=mean.effects.Inds, color=factor(scenario)))+
              geom_line(data=to.plot[which(to.plot$scenario==0),],aes(x=Time, y=mean.effects.Inds), color='black', linetype='dotted')+
              scale_fill_manual(breaks=c(0), values=c("grey")) +
              scale_colour_colorblind() +
              scale_x_continuous(breaks = seq(min(to.plot$Time), max(to.plot$Time), 30),
                                 labels=seq(min(to.plot$year), max(to.plot$year), 1))+
              guides(fill=guide_legend(title="", order=2),color=guide_legend(title="Application rate", order=1)) +
              theme(axis.line = element_line(color = 'black')) +
              ylab("Effect in number of plant individuals") +
              xlab("Year")
            print(IndsP)
            dev.off()
            IndsPlot<-gtkImageNewFromFile("IndsPlot.png")
            
            label_IndsPlot<-gtkLabel('
    Mean effect in number of plant individuals over the selected period. 
    The mean effects per week are shown in solid lines. The black dotted line and the grey ribbon show 
    the mean effect and the 2.5th and 97.5th percentile of the effects in the control simulations.')
            
            vboxInds1$packStart(IndsPlot)
            vboxInds1$packStart(label_IndsPlot)
            
            saveButton <-gtkButton('Save')
            saveButton$setTooltipText('Save the current graphic (without description) at a specified location.')
            SaveDialog <- function(button){
              dialog <- gtkFileChooserDialog ( title = "Save a file" ,
                                               parent = w , action = "save" ,
                                               "gtk-ok" , GtkResponseType [ "ok" ] ,
                                               "gtk-cancel" , GtkResponseType [ "cancel" ] ,
                                               show = FALSE )
              color <-gdkColorToString('white')
              dialog$ModifyBg("normal", color)
              dialog$setCurrentName ("Inds.pdf")
              gSignalConnect ( dialog , "response" ,
                               f = function ( dialog , response , data ) {
                                 if ( response == GtkResponseType [ "ok" ] ) {
                                   filename <- dialog$getFilename ( )
                                   dev <- unlist(strsplit(filename, "[.]"))[2]
                                   dev.ok <- c("ps", "tex", "pdf", "jpeg", "tiff", "png", "bmp", "wmf")
                                   if (dev %in% dev.ok){
                                     ggsave(filename, IndsP)
                                   } else {
                                     dialog_tmp <- gtkMessageDialog(parent=dialog,
                                                                    flags = "destroy-with-parent",
                                                                    type="question" ,
                                                                    buttons="ok" ,
                                                                    "Please ensure that you save the figure as 
                                                                    'ps', 'tex', 'pdf', 'jpeg', 'tiff', 'png', 'bmp'or 'wmf'.")
                                     color <-gdkColorToString('white')
                                     dialog_tmp$ModifyBg("normal", color)
                                     gSignalConnect (dialog_tmp, "response", function(dialog_tmp, response, user.data){ dialog_tmp$Destroy()})
                                     
                                   }
                                   
                                 }
                                 dialog$destroy ( )
                               } )
              
              dialog$run()
            }
            
            gSignalConnect(saveButton, signal = "clicked", SaveDialog)
            
            vboxInds$packStart(vboxInds1)
            vboxInds$packStart(saveButton, fill=F)
            
            Inds$add(vboxInds)
            
            # add popsize graphic frame to notebook
            gtkNotebookAppendPage(GraphicsCom, Inds, tab.label=gtkLabel("Number of plant individuals"))
          }
          
          if ("Shoot mass" %in% variable) {
            # initialize frame for Popsize graphic
            ShootmassCom <- gtkFrame()
            vboxShootmassCom1 <- gtkVBox()
            vboxShootmassCom1$setBorderWidth(10)
            vboxShootmassCom <- gtkVBox()
            vboxShootmassCom$setBorderWidth(10)
            
            png("ShootmassComPlot.png", width=350, height=350)
            ShootmassComP <- ggplot(data=to.plot)+
              theme_tufte(base_family = "sans")+
              geom_ribbon(data=to.plot[which(to.plot$scenario==0),],aes(x=Time, ymin=min.effects.abovemass, ymax=max.effects.abovemass, fill=factor(scenario)))+
              geom_line(data=to.plot[which(to.plot$scenario!=0),],aes(x=Time, y=mean.effects.abovemass, color=factor(scenario)))+
              geom_line(data=to.plot[which(to.plot$scenario==0),],aes(x=Time, y=mean.effects.abovemass), color='black', linetype='dotted')+
              scale_fill_manual(breaks=c(0), values=c("grey")) +
              scale_colour_colorblind() +
              scale_x_continuous(breaks = seq(min(to.plot$Time), max(to.plot$Time), 30),
                                 labels=seq(min(to.plot$year), max(to.plot$year), 1))+
              guides(fill=guide_legend(title="", order=2),color=guide_legend(title="Application rate", order=1)) +
              theme(axis.line = element_line(color = 'black')) +
              ylab("Effect in shoot mass") +
              xlab("Year")
            print(ShootmassComP)
            dev.off()
            ShootmassComPlot<-gtkImageNewFromFile("ShootmassComPlot.png")
            
            label_ShootmassComPlot<-gtkLabel('
    Mean effect in shoot mass over the selected period. 
    The mean effects per week are shown in solid lines. The black dotted line and the grey ribbon show 
    the mean effect and the 2.5th and 97.5th percentile of the effects in the control simulations.')
            
            vboxShootmassCom1$packStart(ShootmassComPlot)
            vboxShootmassCom1$packStart(label_ShootmassComPlot)
            
            saveButton <-gtkButton('Save')
            saveButton$setTooltipText('Save the current graphic (without description) at a specified location.')
            SaveDialog <- function(button){
              dialog <- gtkFileChooserDialog ( title = "Save a file" ,
                                               parent = w , action = "save" ,
                                               "gtk-ok" , GtkResponseType [ "ok" ] ,
                                               "gtk-cancel" , GtkResponseType [ "cancel" ] ,
                                               show = FALSE )
              color <-gdkColorToString('white')
              dialog$ModifyBg("normal", color)
              dialog$setCurrentName ("ShootmassCom.pdf")
              gSignalConnect ( dialog , "response" ,
                               f = function ( dialog , response , data ) {
                                 if ( response == GtkResponseType [ "ok" ] ) {
                                   filename <- dialog$getFilename ( )
                                   dev <- unlist(strsplit(filename, "[.]"))[2]
                                   dev.ok <- c("ps", "tex", "pdf", "jpeg", "tiff", "png", "bmp","wmf")
                                   if (dev %in% dev.ok){
                                     ggsave(filename, ShootmassComP)
                                   } else {
                                     dialog_tmp <- gtkMessageDialog(parent=dialog,
                                                                    flags = "destroy-with-parent",
                                                                    type="question" ,
                                                                    buttons="ok" ,
                                                                    "Please ensure that you save the figure as 
'ps', 'tex', 'pdf', 'jpeg', 'tiff', 'png', 'bmp'or 'wmf'.")
                                     color <-gdkColorToString('white')
                                     dialog_tmp$ModifyBg("normal", color)
                                     gSignalConnect (dialog_tmp, "response", function(dialog_tmp, response, user.data){ dialog_tmp$Destroy()})
                                     
                                   }
                                   
                                 }
                                 dialog$destroy ( )
                               } )
              
              dialog$run()
            }
            
            gSignalConnect(saveButton, signal = "clicked", SaveDialog)
            
            vboxShootmassCom$packStart(vboxShootmassCom1)
            vboxShootmassCom$packStart(saveButton, fill=F)
            
            ShootmassCom$add(vboxShootmassCom)
            
            # add popsize graphic frame to notebook
            gtkNotebookAppendPage(GraphicsCom, ShootmassCom, tab.label=gtkLabel("Shoot mass"))
          }
          
          if ("Diversity" %in% variable) {
            # initialize frame for Popsize graphic
            Diversity <- gtkFrame()
            vboxDiversity <- gtkVBox()
            vboxDiversity$setBorderWidth(10)
            vboxDiversity1 <- gtkVBox()
            vboxDiversity1$setBorderWidth(10)
            
            eveness <- cbind(to.plot[,c(1,2,3,4,5,9,16,23)], Index=rep("Eveness-Index", nrow(to.plot)))
            colnames(eveness) <- c("Time", "scenario", "period", "year", "week", "mean.effects", "max.effects", "min.effects", "Index")
            shannon <- cbind(to.plot[,c(1,2,3,4,5,10,17,24)], Index=rep("Shannon-Index", nrow(to.plot)))
            colnames(shannon) <- c("Time", "scenario", "period", "year", "week", "mean.effects", "max.effects", "min.effects", "Index")
            simpson <- cbind(to.plot[,c(1,2,3,4,5,11,18,25)], Index=rep("Simpson-Index", nrow(to.plot)))
            colnames(simpson) <- c("Time", "scenario", "period", "year", "week", "mean.effects", "max.effects", "min.effects", "Index")
            simpsoninv <- cbind(to.plot[,c(1,2,3,4,5,12,19,26)], Index=rep("Inverse Simpson-Index", nrow(to.plot)))
            colnames(simpsoninv) <- c("Time", "scenario", "period", "year", "week", "mean.effects", "max.effects", "min.effects", "Index")
            
            to.plot.div <- rbind(eveness, shannon, simpson, simpsoninv)
            
            png("DiversityPlot.png", width=350, height=350)
            DiversityP <- ggplot(data=to.plot.div)+
              theme_tufte(base_family = "sans")+
              geom_ribbon(data=to.plot.div[which(to.plot.div$scenario==0),],aes(x=Time, ymin=min.effects, ymax=max.effects, fill=factor(scenario)))+
              geom_line(data=to.plot.div[which(to.plot.div$scenario!=0),],aes(x=Time, y=mean.effects, color=factor(scenario)))+
              geom_line(data=to.plot.div[which(to.plot.div$scenario==0),],aes(x=Time, y=mean.effects), color='black', linetype='dotted')+
              facet_wrap(~factor(Index))+
              scale_fill_manual(breaks=c(0), values=c("grey")) +
              scale_colour_colorblind() +
              scale_x_continuous(breaks = seq(min(to.plot.div$Time), max(to.plot.div$Time), 30),
                                 labels=seq(min(to.plot.div$year), max(to.plot.div$year), 1))+
              guides(fill=guide_legend(title="", order=2),color=guide_legend(title="Application rate", order=1)) +
              theme(axis.line = element_line(color = 'black')) +
              ylab("Effect in diversity indices") +
              xlab("Year")
            print(DiversityP)
            dev.off()
            DiversityPlot<-gtkImageNewFromFile("DiversityPlot.png")
            
            label_DiversityPlot<-gtkLabel('
    Mean effect in diversity over the selected period. 
    The mean effects per week are shown in solid lines. The black dotted line and the grey ribbon show 
    the mean effect and the 2.5th and 97.5th percentile of the effects in the control simulations.
    Eveness: - sum (p_i*log(p_i))/log(S) with s - number of PFTs, p_i - relative abundance of PFT i
    Shannon: - sum (p_i*log(p_i))/log(S) with p_i - relative abundance of PFT i
    Simpson: 1-sum (p_i^2) with p_i - relative abundance of PFT i
    inverse Simpson: 1/sum (p_i^2) with p_i - relative abundance of PFT i')
            
            vboxDiversity1$packStart(DiversityPlot)
            vboxDiversity1$packStart(label_DiversityPlot)
            
            saveButton <-gtkButton('Save')
            saveButton$setTooltipText('Save the current graphic (without description) at a specified location.')
            SaveDialog <- function(button){
              dialog <- gtkFileChooserDialog ( title = "Save a file" ,
                                               parent = w , action = "save" ,
                                               "gtk-ok" , GtkResponseType [ "ok" ] ,
                                               "gtk-cancel" , GtkResponseType [ "cancel" ] ,
                                               show = FALSE )
              color <-gdkColorToString('white')
              dialog$ModifyBg("normal", color)
              dialog$setCurrentName ("Diversity.pdf")
              gSignalConnect ( dialog , "response" ,
                               f = function ( dialog , response , data ) {
                                 if ( response == GtkResponseType [ "ok" ] ) {
                                   filename <- dialog$getFilename ( )
                                   dev <- unlist(strsplit(filename, "[.]"))[2]
                                   dev.ok <- c("ps", "tex", "pdf", "jpeg", "tiff", "png", "bmp", "wmf")
                                   if (dev %in% dev.ok){
                                     ggsave(filename, DiversityP)
                                   } else {
                                     dialog_tmp <- gtkMessageDialog(parent=dialog,
                                                                    flags = "destroy-with-parent",
                                                                    type="question" ,
                                                                    buttons="ok" ,
                                                                    "Please ensure that you save the figure as 
'ps', 'tex', 'pdf', 'jpeg', 'tiff', 'png', 'bmp'or 'wmf'.")
                                     color <-gdkColorToString('white')
                                     dialog_tmp$ModifyBg("normal", color)
                                     gSignalConnect (dialog_tmp, "response", function(dialog_tmp, response, user.data){ dialog_tmp$Destroy()})
                                     
                                   }
                                   
                                 }
                                 dialog$destroy ( )
                               } )
             
              dialog$run()
            }
            
            gSignalConnect(saveButton, signal = "clicked", SaveDialog)
            
            vboxDiversity$packStart(vboxDiversity1)
            vboxDiversity$packStart(saveButton, fill=F)
            
            Diversity$add(vboxDiversity)
            
            # add popsize graphic frame to notebook
            gtkNotebookAppendPage(GraphicsCom, Diversity, tab.label=gtkLabel("Diversity"))
          }
          
          outputComGraphics$add(GraphicsCom)
        }
        
        # if long-term --> effect.year.PFT
        if (length(years.toplot) > 5) {      
          to.plot<-read.table("effect.year.GRD.txt", header=T, sep="\t")
        
          to.plot <- to.plot[which(to.plot$year %in% years.toplot),]
          
          if ("Number of PFTs" %in% variable) {
            # initialize frame for Popsize graphic
            NPFT <- gtkFrame()
            vboxNPFT1 <- gtkVBox()
            vboxNPFT1$setBorderWidth(10)
            vboxNPFT <- gtkVBox()
            vboxNPFT$setBorderWidth(10)
            
            png("NPFTPlot.png", width=350, height=350)
            NPFTP <- ggplot(data=to.plot)+
              theme_tufte(base_family = "sans")+
              geom_ribbon(data=to.plot[which(to.plot$scenario==0),],aes(x=year, ymin=min.effects.NPFT, ymax=max.effects.NPFT, fill=factor(scenario)))+
              geom_line(data=to.plot[which(to.plot$scenario!=0),],aes(x=year, y=mean.effects.NPFT, color=factor(scenario)))+
              geom_line(data=to.plot[which(to.plot$scenario==0),],aes(x=year, y=mean.effects.NPFT), color='black', linetype='dotted')+
              scale_fill_manual(breaks=c(0), values=c("grey")) +
              scale_colour_colorblind() +
              # scale_x_continuous(breaks = seq(min(to.plot$Time), max(to.plot$Time), 30),
              #                    labels=seq(min(to.plot$year), max(to.plot$year), 1))+
              guides(fill=guide_legend(title="", order=2),color=guide_legend(title="Application rate", order=1)) +
              theme(axis.line = element_line(color = 'black')) +
              ylab("Effect in number of PFTs") +
              xlab("Year")
            print(NPFTP)
            dev.off()
            NPFTPlot<-gtkImageNewFromFile("NPFTPlot.png")
            
            label_NPFTPlot<-gtkLabel('
    Mean effect in number of PFTs over the selected period. 
    The mean effects per year are shown in solid lines. The black dotted line and the grey ribbon show 
    the mean effect and the 2.5th and 97.5th percentile of the effects in the control simulations.')
            
            vboxNPFT1$packStart(NPFTPlot)
            vboxNPFT1$packStart(label_NPFTPlot)
            
            saveButton <-gtkButton('Save')
            saveButton$setTooltipText('Save the current graphic (without description) at a specified location.')
            SaveDialog <- function(button){
              dialog <- gtkFileChooserDialog ( title = "Save a file" ,
                                               parent = w , action = "save" ,
                                               "gtk-ok" , GtkResponseType [ "ok" ] ,
                                               "gtk-cancel" , GtkResponseType [ "cancel" ] ,
                                               show = FALSE )
              color <-gdkColorToString('white')
              dialog$ModifyBg("normal", color)
              dialog$setCurrentName ("NPFT.pdf")
              gSignalConnect ( dialog , "response" ,
                               f = function ( dialog , response , data ) {
                                 if ( response == GtkResponseType [ "ok" ] ) {
                                   filename <- dialog$getFilename ( )
                                   dev <- unlist(strsplit(filename, "[.]"))[2]
                                   dev.ok <- c("ps", "tex", "pdf", "jpeg", "tiff", "png", "bmp", "wmf")
                                   if (dev %in% dev.ok){
                                     ggsave(filename, NPFTP)
                                   } else {
                                     dialog_tmp <- gtkMessageDialog(parent=dialog,
                                                                    flags = "destroy-with-parent",
                                                                    type="question" ,
                                                                    buttons="ok" ,
                                                                    "Please ensure that you save the figure as 
'ps', 'tex', 'pdf', 'jpeg', 'tiff', 'png', 'bmp' or 'wmf'.")
                                     color <-gdkColorToString('white')
                                     dialog_tmp$ModifyBg("normal", color)
                                     gSignalConnect (dialog_tmp, "response", function(dialog_tmp, response, user.data){ dialog_tmp$Destroy()})
                                     
                                   }
                                   
                                 }
                                 dialog$destroy ( )
                               } )
             
              dialog$run()
            }
            
            gSignalConnect(saveButton, signal = "clicked", SaveDialog)
            
            vboxNPFT$packStart(vboxNPFT1)
            vboxNPFT$packStart(saveButton, fill=F)
            
            NPFT$add(vboxNPFT)
            
            # add popsize graphic frame to notebook
            gtkNotebookAppendPage(GraphicsCom, NPFT, tab.label=gtkLabel("Number of PFTs"))
          }
          
          if ("Number of plant individuals" %in% variable) {
            # initialize frame for Popsize graphic
            Inds <- gtkFrame()
            vboxInds1 <- gtkVBox()
            vboxInds1$setBorderWidth(10)
            vboxInds <- gtkVBox()
            vboxInds$setBorderWidth(10)
            
            png("IndsPlot.png", width=350, height=350)
            IndsP <- ggplot(data=to.plot)+
              theme_tufte(base_family = "sans")+
              geom_ribbon(data=to.plot[which(to.plot$scenario==0),],aes(x=year, ymin=min.effects.Inds, ymax=max.effects.Inds, fill=factor(scenario)))+
              geom_line(data=to.plot[which(to.plot$scenario!=0),],aes(x=year, y=mean.effects.Inds, color=factor(scenario)))+
              geom_line(data=to.plot[which(to.plot$scenario==0),],aes(x=year, y=mean.effects.Inds), color='black', linetype='dotted')+
              scale_fill_manual(breaks=c(0), values=c("grey")) +
              scale_colour_colorblind() +
              guides(fill=guide_legend(title="", order=2),color=guide_legend(title="Application rate", order=1)) +
              theme(axis.line = element_line(color = 'black')) +
              ylab("Effect in number of plant individuals") +
              xlab("Year")
            print(IndsP)
            dev.off()
            IndsPlot<-gtkImageNewFromFile("IndsPlot.png")
            
            label_IndsPlot<-gtkLabel('
    Mean effect in number of plant individuals over the selected period. 
    The mean effects per year are shown in solid lines. The black dotted line and the grey ribbon show 
    the mean effect and the 2.5th and 97.5th percentile of the effects in the control simulations.')
            
            vboxInds1$packStart(IndsPlot)
            vboxInds1$packStart(label_IndsPlot)
            
            saveButton <-gtkButton('Save')
            saveButton$setTooltipText('Save the current graphic (without description) at a specified location.')
            SaveDialog <- function(button){
              dialog <- gtkFileChooserDialog ( title = "Save a file" ,
                                               parent = w , action = "save" ,
                                               "gtk-ok" , GtkResponseType [ "ok" ] ,
                                               "gtk-cancel" , GtkResponseType [ "cancel" ] ,
                                               show = FALSE )
              color <-gdkColorToString('white')
              dialog$ModifyBg("normal", color)
              dialog$setCurrentName ("Inds.pdf")
              gSignalConnect ( dialog , "response" ,
                               f = function ( dialog , response , data ) {
                                 if ( response == GtkResponseType [ "ok" ] ) {
                                   filename <- dialog$getFilename ( )
                                   dev <- unlist(strsplit(filename, "[.]"))[2]
                                   dev.ok <- c("ps", "tex", "pdf", "jpeg", "tiff", "png", "bmp", "wmf")
                                   if (dev %in% dev.ok){
                                     ggsave(filename, IndsP)
                                   } else {
                                     dialog_tmp <- gtkMessageDialog(parent=dialog,
                                                                    flags = "destroy-with-parent",
                                                                    type="question" ,
                                                                    buttons="ok" ,
                                                                    "Please ensure that you save the figure as 
'ps', 'tex', 'pdf', 'jpeg', 'tiff', 'png', 'bmp'or 'wmf'.")
                                     color <-gdkColorToString('white')
                                     dialog_tmp$ModifyBg("normal", color)
                                     gSignalConnect (dialog_tmp, "response", function(dialog_tmp, response, user.data){ dialog_tmp$Destroy()})
                                     
                                   }
                                   
                                 }
                                 dialog$destroy ( )
                               } )
              
              dialog$run()
            }
            
            gSignalConnect(saveButton, signal = "clicked", SaveDialog)
            
            vboxInds$packStart(vboxInds1)
            vboxInds$packStart(saveButton, fill=F)
            
            Inds$add(vboxInds)
            
            # add popsize graphic frame to notebook
            gtkNotebookAppendPage(GraphicsCom, Inds, tab.label=gtkLabel("Number of plant individuals"))
          }
          
          if ("Shoot mass" %in% variable) {
            # initialize frame for Popsize graphic
            ShootmassCom <- gtkFrame()
            vboxShootmassCom1 <- gtkVBox()
            vboxShootmassCom1$setBorderWidth(10)
            vboxShootmassCom <- gtkVBox()
            vboxShootmassCom$setBorderWidth(10)
            
            png("ShootmassComPlot.png", width=350, height=350)
            ShootmassComP <- ggplot(data=to.plot)+
              theme_tufte(base_family = "sans")+
              geom_ribbon(data=to.plot[which(to.plot$scenario==0),],aes(x=year, ymin=min.effects.abovemass, ymax=max.effects.abovemass, fill=factor(scenario)))+
              geom_line(data=to.plot[which(to.plot$scenario!=0),],aes(x=year, y=mean.effects.abovemass, color=factor(scenario)))+
              geom_line(data=to.plot[which(to.plot$scenario==0),],aes(x=year, y=mean.effects.abovemass), color='black', linetype='dotted')+
              scale_fill_manual(breaks=c(0), values=c("grey")) +
              scale_colour_colorblind() +
              guides(fill=guide_legend(title="", order=2),color=guide_legend(title="Application rate", order=1)) +
              theme(axis.line = element_line(color = 'black')) +
              ylab("Effect in shoot mass") +
              xlab("Year")
            print(ShootmassComP)
            dev.off()
            ShootmassComPlot<-gtkImageNewFromFile("ShootmassComPlot.png")
            
            label_ShootmassComPlot<-gtkLabel('
    Mean effect in shoot mass over the selected period. 
    The mean effects per year are shown in solid lines. The black dotted line and the grey ribbon show 
    the mean effect and the 2.5th and 97.5th percentile of the effects in the control simulations.')
            
            vboxShootmassCom1$packStart(ShootmassComPlot)
            vboxShootmassCom1$packStart(label_ShootmassComPlot)
            
            saveButton <-gtkButton('Save')
            saveButton$setTooltipText('Save the current graphic (without description) at a specified location.')
            SaveDialog <- function(button){
              dialog <- gtkFileChooserDialog ( title = "Save a file" ,
                                               parent = w , action = "save" ,
                                               "gtk-ok" , GtkResponseType [ "ok" ] ,
                                               "gtk-cancel" , GtkResponseType [ "cancel" ] ,
                                               show = FALSE )
              color <-gdkColorToString('white')
              dialog$ModifyBg("normal", color)
              dialog$setCurrentName ("ShootmassCom.pdf")
              gSignalConnect ( dialog , "response" ,
                               f = function ( dialog , response , data ) {
                                 if ( response == GtkResponseType [ "ok" ] ) {
                                   filename <- dialog$getFilename ( )
                                   dev <- unlist(strsplit(filename, "[.]"))[2]
                                   dev.ok <- c("ps", "tex", "pdf", "jpeg", "tiff", "png", "bmp", "wmf")
                                   if (dev %in% dev.ok){
                                     ggsave(filename, ShootmassComP)
                                   } else {
                                     dialog_tmp <- gtkMessageDialog(parent=dialog,
                                                                    flags = "destroy-with-parent",
                                                                    type="question" ,
                                                                    buttons="ok" ,
                                                                    "Please ensure that you save the figure as 
'ps', 'tex', 'pdf', 'jpeg', 'tiff', 'png', 'bmp' or 'wmf'.")
                                     color <-gdkColorToString('white')
                                     dialog_tmp$ModifyBg("normal", color)
                                     gSignalConnect (dialog_tmp, "response", function(dialog_tmp, response, user.data){ dialog_tmp$Destroy()})
                                     
                                   }
                                   
                                 }
                                 dialog$destroy ( )
                               } )
              
              dialog$run()
            }
            
            gSignalConnect(saveButton, signal = "clicked", SaveDialog)
            
            vboxShootmassCom$packStart(vboxShootmassCom1)
            vboxShootmassCom$packStart(saveButton, fill=F)
            
            ShootmassCom$add(vboxShootmassCom)
            
            # add popsize graphic frame to notebook
            gtkNotebookAppendPage(GraphicsCom, ShootmassCom, tab.label=gtkLabel("Shoot mass"))
          }
          
          if ("Diversity" %in% variable) {
            # initialize frame for Popsize graphic
            Diversity <- gtkFrame()
            vboxDiversity1 <- gtkVBox()
            vboxDiversity1$setBorderWidth(10)
            vboxDiversity <- gtkVBox()
            vboxDiversity$setBorderWidth(10)
            
            eveness <- cbind(to.plot[,c(1,2,3,7,14,21)], Index=rep("Eveness-Index", nrow(to.plot)))
            colnames(eveness) <- c("scenario", "year", "period", "mean.effects", "max.effects", "min.effects", "Index")
            shannon <- cbind(to.plot[,c(1,2,3,8,15,22)], Index=rep("Shannon-Index", nrow(to.plot)))
            colnames(shannon) <- c("scenario", "year", "period", "mean.effects", "max.effects", "min.effects","Index")
            simpson <- cbind(to.plot[,c(1,2,3,9,16,23)], Index=rep("Simpson-Index", nrow(to.plot)))
            colnames(simpson) <- c("scenario", "year", "period", "mean.effects", "max.effects", "min.effects", "Index")
            simpsoninv <- cbind(to.plot[,c(1,2,3,10,17,24)], Index=rep("Inverse Simpson-Index", nrow(to.plot)))
            colnames(simpsoninv) <- c("scenario", "year", "period", "mean.effects", "max.effects", "min.effects", "Index")
            
            to.plot.div <- rbind(eveness, shannon, simpson, simpsoninv)
            
            png("DiversityPlot.png", width=350, height=350)
            DiversityP <- ggplot(data=to.plot.div)+
              theme_tufte(base_family = "sans")+
              geom_ribbon(data=to.plot.div[which(to.plot.div$scenario==0),],aes(x=year, ymin=min.effects, ymax=max.effects, fill=factor(scenario)))+
              geom_line(data=to.plot.div[which(to.plot.div$scenario!=0),],aes(x=year, y=mean.effects, color=factor(scenario)))+
              geom_line(data=to.plot.div[which(to.plot.div$scenario==0),],aes(x=year, y=mean.effects), color='black', linetype='dotted')+
              facet_wrap(~factor(Index))+
              scale_fill_manual(breaks=c(0), values=c("grey")) +
              scale_colour_colorblind() +
              guides(fill=guide_legend(title="", order=2),color=guide_legend(title="Application rate", order=1)) +
              theme(axis.line = element_line(color = 'black')) +
              ylab("Effect in diversity indices") +
              xlab("Year")
            print(DiversityP)
            dev.off()
            DiversityPlot<-gtkImageNewFromFile("DiversityPlot.png")
            
            label_DiversityPlot<-gtkLabel('
    Mean effect in diversity over the selected period. 
    The mean effects per week are shown in solid lines. The black dotted line and the grey ribbon show 
    the mean effect and the 2.5th and 97.5th percentile of the effects in the control simulations.
    Eveness: - sum (p_i*log(p_i))/log(S) with s - number of PFTs, p_i - relative abundance of PFT i
    Shannon: - sum (p_i*log(p_i))/log(S) with p_i - relative abundance of PFT i
    Simpson: 1-sum (p_i^2) with p_i - relative abundance of PFT i
    inverse Simpson: 1/sum (p_i^2) with p_i - relative abundance of PFT i')
            
            vboxDiversity1$packStart(DiversityPlot)
            vboxDiversity1$packStart(label_DiversityPlot)
            
            saveButton <-gtkButton('Save')
            saveButton$setTooltipText('Save the current graphic (without description) at a specified location.')
            SaveDialog <- function(button){
              dialog <- gtkFileChooserDialog ( title = "Save a file" ,
                                               parent = w , action = "save" ,
                                               "gtk-ok" , GtkResponseType [ "ok" ] ,
                                               "gtk-cancel" , GtkResponseType [ "cancel" ] ,
                                               show = FALSE )
              color <-gdkColorToString('white')
              dialog$ModifyBg("normal", color)
              dialog$setCurrentName ("Diversity.pdf")
              gSignalConnect ( dialog , "response" ,
                               f = function ( dialog , response , data ) {
                                 if ( response == GtkResponseType [ "ok" ] ) {
                                   filename <- dialog$getFilename ( )
                                   dev <- unlist(strsplit(filename, "[.]"))[2]
                                   dev.ok <- c("ps", "tex", "pdf", "jpeg", "tiff", "png", "bmp", "wmf")
                                   if (dev %in% dev.ok){
                                     ggsave(filename, DiversityP)
                                   } else {
                                     dialog_tmp <- gtkMessageDialog(parent=dialog,
                                                                    flags = "destroy-with-parent",
                                                                    type="question" ,
                                                                    buttons="ok" ,
                                                                    "Please ensure that you save the figure as 
'ps', 'tex', 'pdf', 'jpeg', 'tiff', 'png', 'bmp' or 'wmf'.")
                                     color <-gdkColorToString('white')
                                     dialog_tmp$ModifyBg("normal", color)
                                     gSignalConnect (dialog_tmp, "response", function(dialog_tmp, response, user.data){ dialog_tmp$Destroy()})
                                     
                                   }
                                   
                                 }
                                 dialog$destroy ( )
                               } )
             
              dialog$run()
            }
            
            gSignalConnect(saveButton, signal = "clicked", SaveDialog)
            
            vboxDiversity$packStart(vboxDiversity1)
            vboxDiversity$packStart(saveButton, fill=F)
            
            Diversity$add(vboxDiversity)
            
            # add popsize graphic frame to notebook
            gtkNotebookAppendPage(GraphicsCom, Diversity, tab.label=gtkLabel("Diversity"))
          }
          
        outputComGraphics$add(GraphicsCom)
        }
        ShowGraphicsCom$label<-'Update graphics'
        } else{
          dialog <- gtkMessageDialog(parent=w,
                                     flags = "destroy-with-parent",
                                     type="question" ,
                                     buttons="ok" ,
                                     "Please ensure that you select at least one variable.")
          color <-gdkColorToString('white')
          dialog$ModifyBg("normal", color)
          gSignalConnect (dialog, "response", function(dialog, response, user.data){ dialog$Destroy()})
        }
      
    } else{
        dialog <- gtkMessageDialog(parent=w,
                                   flags = "destroy-with-parent",
                                   type="question" ,
                                   buttons="ok" ,
                                   "Please ensure that the first year you would like to plot is smaller than the last year.")
        color <-gdkColorToString('white')
        dialog$ModifyBg("normal", color)
        gSignalConnect (dialog, "response", function(dialog, response, user.data){ dialog$Destroy()})
      }
   
  }
  ##################################################
  ### Show tables Pop function
  ##################################################
  ShowTablesPopFct <- function(button){
    # clean input of outputPopGraphics
    if(length(outputPopTable$getChildren())!=0) outputPopTable$remove(outputPopTable$getChildren()[[1]])
    #
    TablePop<-gtkNotebook()
    # get years
    start_year <- StartYearSliderPop$getValue()
    end_year <- EndYearSliderPop$getValue()
    
    if(end_year>start_year){
      years.toshow <- c(start_year:end_year)
      # get the list of PFTs that should be plotted
      PFT.toshow<-c()
      for(i in 1:length(PFTs)){
        place <- i
        if (vboxPFTs[[place]]$getActive()) PFT.toshow<-c(PFT.toshow,PFTs[i])
      }
       if (length(PFT.toshow)!=0){
          variable<-c()
          for(i in 1:length(variables.PFT)){
            place <- i
            if (vboxVariablesPop[[place]]$getActive()) variable<-c(variable,variables.PFT[i])
          }
          if (length(variable)!=0){
            # read in file
      
            if ("Population size" %in% variable) {
              # initialize frame 
              TabPopSize <- gtkFrame()
              vboxTabPopSize <- gtkVBox()
      
              to.show<-read.table("Inds_PFT.txt", header=T, sep="\t")
              
              to.show <- to.show[which(to.show$PFT %in% PFT.toshow),]
              to.show <- to.show[which(to.show$year %in% years.toshow),]
              to.show.popsize <- to.show
              
              NotebookPopSize <- gtkNotebook()
              for (level in levels(factor(to.show.popsize$Application.rate))){
                levelFrame <- gtkFrame()
                vboxhelp <- gtkVBoxNew()
                vboxhelp$setBorderWidth(5)
                # header
                label_level <- gtkLabel()
                label_level$setMarkup(
'<span weight=\"bold\" size=\"large\">The table shows the number of weeks in which the mean (minimum and maximum) effect 
on the PFT specific population size is within a certain effect class</span> . 
<span size=\"large\">Only negative effects are considered. For positive effects have a look at the different graphics.
Please note that IBC-grass only simulations the growing period of 30 weeks. 
Thus, the maximal number of weeks can only be 30.</span> ')
                label_level['height.request'] <- 100
                # the table to show
                levelTab <- gtkScrolledWindow()
                levelTab['height.request'] <- 300
                to.show.level.popsize <- to.show.popsize[to.show.popsize$Application.rate==level,]
                to.show.level.popsize<-data.frame(
                  to.show.level.popsize[,1:3],
                  '<10'=apply(to.show.level.popsize, 1, function(x){
                    paste(x[4], '(', x[5], x[6],')' )}),
                  '10-20'=apply(to.show.level.popsize, 1, function(x){
                    paste(x[7], '(', x[8], x[9],')' )}),
                  '20-30'=apply(to.show.level.popsize, 1, function(x){
                    paste(x[10], '(', x[11], x[12],')' )}),
                  '30-40'=apply(to.show.level.popsize, 1, function(x){
                    paste(x[13], '(', x[14], x[15],')' )}),
                  '40-50'=apply(to.show.level.popsize, 1, function(x){
                    paste(x[16], '(', x[17], x[18],')' )}),
                  '>50'=apply(to.show.level.popsize, 1, function(x){
                    paste(x[19], '(', x[20], x[21],')' )}))
                to.show.level.popsize$PFT <- as.character(to.show.level.popsize$PFT)
                colnames(to.show.level.popsize) <- c(paste('Application rate'), paste('PFT'), paste('Year'),
                                             paste('< 10'), paste('10 - 20'), paste('20 - 30')
                                             , paste('30 - 40'), paste('40 - 50'), paste('> 50'))
      
                store <- rGtkDataFrame(to.show.level.popsize)
                view <- gtkTreeView(store)
                nms <- names(to.show.level.popsize)
                QT <- sapply(1:ncol(to.show.level.popsize), function(i) {
                  type <- class(to.show.level.popsize[,i])[1]
                  view$addColumnWithType(name = nms[i], type, viewCol = i, storeCol = i)
                })
                levelTab$add(view)
                
                vboxhelp$packStart(label_level)
                vboxhelp$packStart(levelTab)
                levelFrame$add(vboxhelp)
                levelFrame$setTooltipText('IBC-grass simulates only the growing period of 30 weeks. Thus, one modelled year consists of 30 weeks.')
                gtkNotebookAppendPage(NotebookPopSize, levelFrame, tab.label=gtkLabel(paste('Application rate: ',level)))
              }
              
              vboxTabPopSize$packStart(NotebookPopSize)
              
              saveButton <-gtkButton('Save')
              saveButton$setTooltipText('Save the current tabs of this endpoints in a .txt file.')
              SaveDialog <- function(button){
                dialog <- gtkFileChooserDialog ( title = "Save a file" ,
                                                 parent = w , action = "save" ,
                                                 "gtk-ok" , GtkResponseType [ "ok" ] ,
                                                 "gtk-cancel" , GtkResponseType [ "cancel" ] ,
                                                 show = FALSE )
                color <-gdkColorToString('white')
                dialog$ModifyBg("normal", color)
                dialog$setCurrentName ("PopSize.txt")
                gSignalConnect ( dialog , "response" ,
                                 f = function ( dialog , response , data ) {
                                   if ( response == GtkResponseType [ "ok" ] ) {
                                     filename <- dialog$getFilename ( )
                                     dev <- unlist(strsplit(filename, "[.]"))[2]
                                     dev.ok <- "txt"
                                     if (dev %in% dev.ok){
                                       write.table(to.show.popsize, filename, sep="\t", row.names=F)
                                     } else {
                                       dialog_tmp <- gtkMessageDialog(parent=dialog,
                                                                      flags = "destroy-with-parent",
                                                                      type="question" ,
                                                                      buttons="ok" ,
                                                                      "Please ensure that you save the table as 'txt'.")
                                       color <-gdkColorToString('white')
                                       dialog_tmp$ModifyBg("normal", color)
                                       gSignalConnect (dialog_tmp, "response", function(dialog_tmp, response, user.data){ dialog_tmp$Destroy()})
                                       
                                     }
                                   }
                                   dialog$destroy ( )
                                 } )
                
                dialog$run()
              }
              
              gSignalConnect(saveButton, signal = "clicked", SaveDialog)
              
              vboxTabPopSize$packStart(saveButton, fill=F)
              
              TabPopSize$add(vboxTabPopSize)
              
              # add popsize graphic frame to notebook
              gtkNotebookAppendPage(TablePop, TabPopSize, tab.label=gtkLabel("Population size"))
            }
            
            if ("Shoot mass" %in% variable) {
              # initialize frame 
              TabShootmass <- gtkFrame()
              vboxTabShootmass <-gtkVBox()
              
              to.show<-read.table("shootmass_PFT.txt", header=T, sep="\t")
              
              to.show <- to.show[which(to.show$PFT %in% PFT.toshow),]
              to.show <- to.show[which(to.show$year %in% years.toshow),]
              to.show.shootmass <- to.show
              
              NotebookShootmass <- gtkNotebook()
              for (level in levels(factor(to.show.shootmass$Application.rate))){
                levelFrame <- gtkFrame()
                vboxhelp <- gtkVBoxNew()
                vboxhelp$setBorderWidth(5)
                # header
                label_level <- gtkLabel()
                label_level$setMarkup(
'<span weight=\"bold\" size=\"large\">The table shows the number of weeks in which the mean (minimum and maximum) effect 
on the PFT specific shoot mass is within a certain effect class</span> . 
<span size=\"large\">Only negative effects are considered. For positive effects have a look at the different graphics.
Please note that IBC-grass only simulations the growing period of 30 weeks. 
Thus, the maximal number of weeks can only be 30.</span> ')
                label_level['height.request'] <- 100
                # the table to show
                levelTab <- gtkScrolledWindow()
                levelTab['height.request'] <- 300
                to.show.level.shootmass <- to.show.shootmass[to.show.shootmass$Application.rate==level,]
                to.show.level.shootmass<-data.frame(
                  to.show.level.shootmass[,1:3],
                  '<10'=apply(to.show.level.shootmass, 1, function(x){
                    paste(x[4], '(', x[5], x[6],')' )}),
                  '10-20'=apply(to.show.level.shootmass, 1, function(x){
                    paste(x[7], '(', x[8], x[9],')' )}),
                  '20-30'=apply(to.show.level.shootmass, 1, function(x){
                    paste(x[10], '(', x[11], x[12],')' )}),
                  '30-40'=apply(to.show.level.shootmass, 1, function(x){
                    paste(x[13], '(', x[14], x[15],')' )}),
                  '40-50'=apply(to.show.level.shootmass, 1, function(x){
                    paste(x[16], '(', x[17], x[18],')' )}),
                  '>50'=apply(to.show.level.shootmass, 1, function(x){
                    paste(x[19], '(', x[20], x[21],')' )}))
                to.show.level.shootmass$PFT <- as.character(to.show.level.shootmass$PFT)
                colnames(to.show.level.shootmass) <- c(paste('Application rate'), paste('PFT'), paste('Year'),
                                             paste('< 10'), paste('10 - 20'), paste('20 - 30')
                                             , paste('30 - 40'), paste('40 - 50'), paste('> 50'))
                
                store <- rGtkDataFrame(to.show.level.shootmass)
                view <- gtkTreeView(store)
                nms <- names(to.show.level.shootmass)
                QT <- sapply(1:ncol(to.show.level.shootmass), function(i) {
                  type <- class(to.show.level.shootmass[,i])[1]
                  view$addColumnWithType(name = nms[i], type, viewCol = i, storeCol = i)
                })
                levelTab$add(view)
                
                vboxhelp$packStart(label_level)
                vboxhelp$packStart(levelTab)
                levelFrame$add(vboxhelp)
                levelFrame$setTooltipText('IBC-grass simulates only the growing period of 30 weeks. Thus, one modelled year consists of 30 weeks.')
                gtkNotebookAppendPage(NotebookShootmass, levelFrame, tab.label=gtkLabel(paste('Application rate: ',level)))
              }
              
              vboxTabShootmass$packStart(NotebookShootmass)
              
              saveButton <-gtkButton('Save')
              saveButton$setTooltipText('Save the current tabs of this endpoints in a .txt file.')
              SaveDialog <- function(button){
                dialog <- gtkFileChooserDialog ( title = "Save a file" ,
                                                 parent = w , action = "save" ,
                                                 "gtk-ok" , GtkResponseType [ "ok" ] ,
                                                 "gtk-cancel" , GtkResponseType [ "cancel" ] ,
                                                 show = FALSE )
                color <-gdkColorToString('white')
                dialog$ModifyBg("normal", color)
                dialog$setCurrentName ("ShootmassPop.txt")
                gSignalConnect ( dialog , "response" ,
                                 f = function ( dialog , response , data ) {
                                   if ( response == GtkResponseType [ "ok" ] ) {
                                     filename <- dialog$getFilename ( )
                                     dev <- unlist(strsplit(filename, "[.]"))[2]
                                     dev.ok <- "txt"
                                     if (dev %in% dev.ok){
                                       write.table(to.show.shootmass, filename, sep="\t", row.names=F)
                                     } else {
                                       dialog_tmp <- gtkMessageDialog(parent=dialog,
                                                                      flags = "destroy-with-parent",
                                                                      type="question" ,
                                                                      buttons="ok" ,
                                                                      "Please ensure that you save the table as 'txt'.")
                                       color <-gdkColorToString('white')
                                       dialog_tmp$ModifyBg("normal", color)
                                       gSignalConnect (dialog_tmp, "response", function(dialog_tmp, response, user.data){ dialog_tmp$Destroy()})
                                       
                                     }
                                     
                                   }
                                   dialog$destroy ( )
                                 } )
                
                dialog$run()
              }
              
              gSignalConnect(saveButton, signal = "clicked", SaveDialog)
              
              vboxTabShootmass$packStart(saveButton, fill=F)
              
              TabShootmass$add(vboxTabShootmass)
              
              # add popsize graphic frame to notebook
              gtkNotebookAppendPage(TablePop, TabShootmass, tab.label=gtkLabel("Shoot mass"))
            }
            
            if ("Cover" %in% variable) {
              # initialize frame 
              TabCover <- gtkFrame()
              vboxTabCover <- gtkVBox()
              
              to.show<-read.table("cover_PFT.txt", header=T, sep="\t")
              
              to.show <- to.show[which(to.show$PFT %in% PFT.toshow),]
              to.show <- to.show[which(to.show$year %in% years.toshow),]
              to.show.cover <- to.show
              
              NotebookCover <- gtkNotebook()
              for (level in levels(factor(to.show.cover$Application.rate))){
                levelFrame <- gtkFrame()
                vboxhelp <- gtkVBoxNew()
                vboxhelp$setBorderWidth(5)
                # header
                label_level <- gtkLabel()
                label_level$setMarkup(
'<span weight=\"bold\" size=\"large\">The table shows the number of weeks in which the mean (minimum and maximum) effect 
on the PFT specific cover is within a certain effect class</span> . 
<span size=\"large\">Only negative effects are considered. For positive effects have a look at the different graphics.
Please note that IBC-grass only simulations the growing period of 30 weeks. 
Thus, the maximal number of weeks can only be 30.</span> ')
                label_level['height.request'] <- 100
                # the table to show
                levelTab <- gtkScrolledWindow()
                levelTab['height.request'] <- 300
                to.show.level.cover <- to.show.cover[to.show.cover$Application.rate==level,]
                to.show.level.cover<-data.frame(
                  to.show.level.cover[,1:3],
                  '<10'=apply(to.show.level.cover, 1, function(x){
                    paste(x[4], '(', x[5], x[6],')' )}),
                  '10-20'=apply(to.show.level.cover, 1, function(x){
                    paste(x[7], '(', x[8], x[9],')' )}),
                  '20-30'=apply(to.show.level.cover, 1, function(x){
                    paste(x[10], '(', x[11], x[12],')' )}),
                  '30-40'=apply(to.show.level.cover, 1, function(x){
                    paste(x[13], '(', x[14], x[15],')' )}),
                  '40-50'=apply(to.show.level.cover, 1, function(x){
                    paste(x[16], '(', x[17], x[18],')' )}),
                  '>50'=apply(to.show.level.cover, 1, function(x){
                    paste(x[19], '(', x[20], x[21],')' )}))
                to.show.level.cover$PFT <- as.character(to.show.level.cover$PFT)
                colnames(to.show.level.cover) <- c(paste('Application rate'), paste('PFT'), paste('Year'),
                                             paste('< 10'), paste('10 - 20'), paste('20 - 30')
                                             , paste('30 - 40'), paste('40 - 50'), paste('> 50'))
                
                store <- rGtkDataFrame(to.show.level.cover)
                view <- gtkTreeView(store)
                nms <- names(to.show.level.cover)
                QT <- sapply(1:ncol(to.show.level.cover), function(i) {
                  type <- class(to.show.level.cover[,i])[1]
                  view$addColumnWithType(name = nms[i], type, viewCol = i, storeCol = i)
                })
                levelTab$add(view)
                
                vboxhelp$packStart(label_level)
                vboxhelp$packStart(levelTab)
                levelFrame$add(vboxhelp)
                levelFrame$setTooltipText('IBC-grass simulates only the growing period of 30 weeks. Thus, one modelled year consists of 30 weeks.')
                gtkNotebookAppendPage(NotebookCover, levelFrame, tab.label=gtkLabel(paste('Application rate: ',level)))
              }
              
              vboxTabCover$packStart(NotebookCover)
              
              saveButton <-gtkButton('Save')
              saveButton$setTooltipText('Save the current tabs of this endpoints in a .txt file.')
              SaveDialog <- function(button){
                dialog <- gtkFileChooserDialog ( title = "Save a file" ,
                                                 parent = w , action = "save" ,
                                                 "gtk-ok" , GtkResponseType [ "ok" ] ,
                                                 "gtk-cancel" , GtkResponseType [ "cancel" ] ,
                                                 show = FALSE )
                color <-gdkColorToString('white')
                dialog$ModifyBg("normal", color)
                dialog$setCurrentName ("Cover.txt")
                gSignalConnect ( dialog , "response" ,
                                 f = function ( dialog , response , data ) {
                                   if ( response == GtkResponseType [ "ok" ] ) {
                                     filename <- dialog$getFilename ( )
                                     dev <- unlist(strsplit(filename, "[.]"))[2]
                                     dev.ok <- "txt"
                                     if (dev %in% dev.ok){
                                       write.table(to.show.cover, filename, sep="\t", row.names=F)
                                     } else {
                                       dialog_tmp <- gtkMessageDialog(parent=dialog,
                                                                      flags = "destroy-with-parent",
                                                                      type="question" ,
                                                                      buttons="ok" ,
                                                                      "Please ensure that you save the table as 'txt'.")
                                       color <-gdkColorToString('white')
                                       dialog_tmp$ModifyBg("normal", color)
                                       gSignalConnect (dialog_tmp, "response", function(dialog_tmp, response, user.data){ dialog_tmp$Destroy()})
                                       
                                     }
                                   }
                                   dialog$destroy ( )
                                 } )
                dialog$run()
              }
              
              gSignalConnect(saveButton, signal = "clicked", SaveDialog)
              
              vboxTabCover$packStart(saveButton, fill=F)
              
              TabCover$add(vboxTabCover)
              
              # add graphic frame to notebook
              gtkNotebookAppendPage(TablePop, TabCover, tab.label=gtkLabel("Cover"))
            }
            
            outputPopTable$add(TablePop)
            ShowTablesPop$label<-'Update tables'
          } else {
            dialog <- gtkMessageDialog(parent=w,
                                       flags = "destroy-with-parent",
                                       type="question" ,
                                       buttons="ok" ,
                                       "Please ensure that you select at least one variable.")
            color <-gdkColorToString('white')
            dialog$ModifyBg("normal", color)
            gSignalConnect (dialog, "response", function(dialog, response, user.data){ dialog$Destroy()})
          }
       } else {
         dialog <- gtkMessageDialog(parent=w,
                                    flags = "destroy-with-parent",
                                    type="question" ,
                                    buttons="ok" ,
                                    "Please ensure that you select at least one PFT.")
         color <-gdkColorToString('white')
         dialog$ModifyBg("normal", color)
         gSignalConnect (dialog, "response", function(dialog, response, user.data){ dialog$Destroy()})
       }
      } else{
      dialog <- gtkMessageDialog(parent=w,
                                 flags = "destroy-with-parent",
                                 type="question" ,
                                 buttons="ok" ,
                                 "Please ensure that the first year you would like to show is smaller than the last year.")
      color <-gdkColorToString('white')
      dialog$ModifyBg("normal", color)
      gSignalConnect (dialog, "response", function(dialog, response, user.data){ dialog$Destroy()})
    }
    
  }
  ##################################################
  ### Show tables com function
  ##################################################
  ShowTablesComFct <- function(button){
    # clean input of outputPopGraphics
    if(length(outputComTable$getChildren())!=0) outputComTable$remove(outputComTable$getChildren()[[1]])
    #
    TableCom<-gtkNotebook()
    # get years
    start_year <- StartYearSliderCom$getValue()
    end_year <- EndYearSliderCom$getValue()
    
    if(end_year>start_year){
      years.toshow <- c(start_year:end_year)
      # get the variables
      # determines how many notebooks in this current one
      variable<-c()
      for(i in 1:length(variables.GRD)){
        place <- i
        if (vboxVariables[[place]]$getActive()) variable<-c(variable,variables.GRD[i])
      }
      if (length(variable)!=0){
        # read in file
      
      if ("Number of PFTs" %in% variable) {
        # initialize frame 
        TabNPFT <- gtkFrame()
        vboxTabNPFT <- gtkVBox()
        
        to.show<-read.table("NPFT_GRD.txt", header=T, sep="\t")
        
        to.show <- to.show[which(to.show$year %in% years.toshow),]
        to.show.NPFT <- to.show
        
        NotebookNPFT <- gtkNotebook()
        for (level in levels(factor(to.show.NPFT$Application.rate))){
          levelFrame <- gtkFrame()
          vboxhelp <- gtkVBoxNew()
          vboxhelp$setBorderWidth(10)
          # header
          label_level <- gtkLabel()
          label_level$setMarkup(
'<span weight=\"bold\" size=\"large\">The table shows the number of weeks in which the mean (minimum and maximum) effect 
on the number of PFTs is within a certain effect class</span> . 
<span size=\"large\">Only negative effects are considered. For positive effects have a look at the different graphics.
Please note that IBC-grass only simulations the growing period of 30 weeks. 
Thus, the maximal number of weeks can only be 30.</span> ')
          label_level['height.request'] <- 100
          # the table to show
          levelTab <- gtkScrolledWindow()
          levelTab['height.request'] <- 300
          to.show.level.NPFT <- to.show.NPFT[to.show.NPFT$Application.rate==level,]
          to.show.level.NPFT<-data.frame(
            to.show.level.NPFT[,1:2],
            '<10'=apply(to.show.level.NPFT, 1, function(x){
              paste(x[3], '(', x[4], x[5],')' )}),
            '10-20'=apply(to.show.level.NPFT, 1, function(x){
              paste(x[6], '(', x[7], x[8],')' )}),
            '20-30'=apply(to.show.level.NPFT, 1, function(x){
              paste(x[9], '(', x[10], x[11],')' )}),
            '30-40'=apply(to.show.level.NPFT, 1, function(x){
              paste(x[12], '(', x[13], x[14],')' )}),
            '40-50'=apply(to.show.level.NPFT, 1, function(x){
              paste(x[15], '(', x[16], x[17],')' )}),
            '>50'=apply(to.show.level.NPFT, 1, function(x){
              paste(x[18], '(', x[19], x[20],')' )}))
          colnames(to.show.level.NPFT) <- c(paste('Application rate'), paste('Year'),
                                       paste('< 10'), paste('10 - 20'), paste('20 - 30')
                                       , paste('30 - 40'), paste('40 - 50'), paste('> 50'))
          
          store <- rGtkDataFrame(to.show.level.NPFT)
          view <- gtkTreeView(store)
          nms <- names(to.show.level.NPFT)
          QT <- sapply(1:ncol(to.show.level.NPFT), function(i) {
            type <- class(to.show.level.NPFT[,i])[1]
            view$addColumnWithType(name = nms[i], type, viewCol = i, storeCol = i)
          })
          levelTab$add(view)
          
          vboxhelp$packStart(label_level)
          vboxhelp$packStart(levelTab)
          levelFrame$add(vboxhelp)
          levelFrame$setTooltipText('IBC-grass simulates only the growing period of 30 weeks. Thus, one modelled year consists of 30 weeks.')
          gtkNotebookAppendPage(NotebookNPFT, levelFrame, tab.label=gtkLabel(paste('Application rate: ',level)))
        }
        
        vboxTabNPFT$packStart(NotebookNPFT)
        
        saveButton <-gtkButton('Save')
        saveButton$setTooltipText('Save the current tabs of this endpoints in a .txt file.')
        SaveDialog <- function(button){
          dialog <- gtkFileChooserDialog ( title = "Save a file" ,
                                           parent = w , action = "save" ,
                                           "gtk-ok" , GtkResponseType [ "ok" ] ,
                                           "gtk-cancel" , GtkResponseType [ "cancel" ] ,
                                           show = FALSE )
          color <-gdkColorToString('white')
          dialog$ModifyBg("normal", color)
          dialog$setCurrentName ("NPFT.txt")
          gSignalConnect ( dialog , "response" ,
                           f = function ( dialog , response , data ) {
                             if ( response == GtkResponseType [ "ok" ] ) {
                               filename <- dialog$getFilename ( )
                               dev <- unlist(strsplit(filename, "[.]"))[2]
                               dev.ok <- "txt"
                               if (dev %in% dev.ok){
                                 write.table(to.show.NPFT, filename, sep="\t", row.names=F)
                               } else {
                                 dialog_tmp <- gtkMessageDialog(parent=dialog,
                                                                flags = "destroy-with-parent",
                                                                type="question" ,
                                                                buttons="ok" ,
                                                                "Please ensure that you save the table as 'txt'.")
                                 color <-gdkColorToString('white')
                                 dialog_tmp$ModifyBg("normal", color)
                                 gSignalConnect (dialog_tmp, "response", function(dialog_tmp, response, user.data){ dialog_tmp$Destroy()})
                                 
                               }
                             }
                             dialog$destroy ( )
                           } )
          
          dialog$run()
        }
        
        gSignalConnect(saveButton, signal = "clicked", SaveDialog)
        
        vboxTabNPFT$packStart(saveButton, fill=F)
        
        TabNPFT$add(vboxTabNPFT)
        
        # add popsize graphic frame to notebook
        gtkNotebookAppendPage(TableCom, TabNPFT, tab.label=gtkLabel("Number of PFTs"))
      }
      
      if ("Number of plant individuals" %in% variable) {
        # initialize frame 
        TabInds <- gtkFrame()
        vboxTabInds <- gtkVBox()
        
        to.show<-read.table("Inds_GRD.txt", header=T, sep="\t")
        
        to.show <- to.show[which(to.show$year %in% years.toshow),]
        to.show.Inds <- to.show
        
        
        NotebookInds <- gtkNotebook()
        for (level in levels(factor(to.show.Inds$Application.rate))){
          levelFrame <- gtkFrame()
          vboxhelp <- gtkVBoxNew()
          vboxhelp$setBorderWidth(10)
          # header
          label_level <- gtkLabel()
          label_level$setMarkup(
'<span weight=\"bold\" size=\"large\">The table shows the number of weeks in which the mean (minimum and maximum) effect 
on the number of plant individuals is within a certain effect class</span> . 
<span size=\"large\">Only negative effects are considered. For positive effects have a look at the different graphics.
Please note that IBC-grass only simulations the growing period of 30 weeks. 
Thus, the maximal number of weeks can only be 30.</span> ')
          label_level['height.request'] <- 100
          # the table to show
          levelTab <- gtkScrolledWindow()
          levelTab['height.request'] <- 300
          to.show.level.Inds <- to.show.Inds[to.show.Inds$Application.rate==level,]
          to.show.level.Inds<-data.frame(
            to.show.level.Inds[,1:2],
            '<10'=apply(to.show.level.Inds, 1, function(x){
              paste(x[3], '(', x[4], x[5],')' )}),
            '10-20'=apply(to.show.level.Inds, 1, function(x){
              paste(x[6], '(', x[7], x[8],')' )}),
            '20-30'=apply(to.show.level.Inds, 1, function(x){
              paste(x[9], '(', x[10], x[11],')' )}),
            '30-40'=apply(to.show.level.Inds, 1, function(x){
              paste(x[12], '(', x[13], x[14],')' )}),
            '40-50'=apply(to.show.level.Inds, 1, function(x){
              paste(x[15], '(', x[16], x[17],')' )}),
            '>50'=apply(to.show.level.Inds, 1, function(x){
              paste(x[18], '(', x[19], x[20],')' )}))
          colnames(to.show.level.Inds) <- c(paste('Application rate'), paste('Year'),
                                       paste('< 10'), paste('10 - 20'), paste('20 - 30')
                                       , paste('30 - 40'), paste('40 - 50'), paste('> 50'))
          
          store <- rGtkDataFrame(to.show.level.Inds)
          view <- gtkTreeView(store)
          nms <- names(to.show.level.Inds)
          QT <- sapply(1:ncol(to.show.level.Inds), function(i) {
            type <- class(to.show.level.Inds[,i])[1]
            view$addColumnWithType(name = nms[i], type, viewCol = i, storeCol = i)
          })
          levelTab$add(view)
          
          vboxhelp$packStart(label_level)
          vboxhelp$packStart(levelTab)
          levelFrame$add(vboxhelp)
          levelFrame$setTooltipText('IBC-grass simulates only the growing period of 30 weeks. Thus, one modelled year consists of 30 weeks.')
          gtkNotebookAppendPage(NotebookInds, levelFrame, tab.label=gtkLabel(paste('Application rate: ',level)))
        }
        
        vboxTabInds$packStart(NotebookInds)
        
        saveButton <-gtkButton('Save')
        saveButton$setTooltipText('Save the current tabs of this endpoints in a .txt file.')
        SaveDialog <- function(button){
          dialog <- gtkFileChooserDialog ( title = "Save a file" ,
                                           parent = w , action = "save" ,
                                           "gtk-ok" , GtkResponseType [ "ok" ] ,
                                           "gtk-cancel" , GtkResponseType [ "cancel" ] ,
                                           show = FALSE )
          color <-gdkColorToString('white')
          dialog$ModifyBg("normal", color)
          dialog$setCurrentName ("Inds.txt")
          gSignalConnect ( dialog , "response" ,
                           f = function ( dialog , response , data ) {
                             if ( response == GtkResponseType [ "ok" ] ) {
                               filename <- dialog$getFilename ( )
                               dev <- unlist(strsplit(filename, "[.]"))[2]
                               dev.ok <- "txt"
                               if (dev %in% dev.ok){
                                 write.table(to.show.Inds, filename, sep="\t", row.names=F)
                               } else {
                                 dialog_tmp <- gtkMessageDialog(parent=dialog,
                                                                flags = "destroy-with-parent",
                                                                type="question" ,
                                                                buttons="ok" ,
                                                                "Please ensure that you save the table as 'txt'.")
                                 color <-gdkColorToString('white')
                                 dialog_tmp$ModifyBg("normal", color)
                                 gSignalConnect (dialog_tmp, "response", function(dialog_tmp, response, user.data){ dialog_tmp$Destroy()})
                                 
                               }
                             }
                             dialog$destroy ( )
                           } )
          
          dialog$run()
        }
        
        gSignalConnect(saveButton, signal = "clicked", SaveDialog)
        
        vboxTabInds$packStart(saveButton, fill=F)
        
        TabInds$add(vboxTabInds)
        
        # add popsize graphic frame to notebook
        gtkNotebookAppendPage(TableCom, TabInds, tab.label=gtkLabel("Number of plant individuals"))
      }
      
      if ("Shoot mass" %in% variable) {
        # initialize frame 
        TabShootmass <- gtkFrame()
        vboxTabShootmass <- gtkVBox()
        
        to.show<-read.table("shootmass_GRD.txt", header=T, sep="\t")
        
        to.show.shootmasscom <- to.show[which(to.show$year %in% years.toshow),]
        
        
        NotebookShootmass <- gtkNotebook()
        for (level in levels(factor(to.show.shootmasscom$Application.rate))){
          levelFrame <- gtkFrame()
          vboxhelp <- gtkVBoxNew()
          vboxhelp$setBorderWidth(5)
          # header
          label_level <- gtkLabel()
          label_level$setMarkup(
'<span weight=\"bold\" size=\"large\">The table shows the number of weeks in which the mean (minimum and maximum) effect 
on the shoot mass is within a certain effect class</span> . 
<span size=\"large\">Only negative effects are considered. For positive effects have a look at the different graphics.
Please note that IBC-grass only simulations the growing period of 30 weeks. 
Thus, the maximal number of weeks can only be 30.</span> ')
          label_level['height.request'] <- 100
          # the table to show
          levelTab <- gtkScrolledWindow()
          levelTab['height.request'] <- 300
          to.show.level.shootmasscom <- to.show.shootmasscom[to.show.shootmasscom$Application.rate==level,]
          to.show.level.shootmasscom<-data.frame(
            to.show.level.shootmasscom[,1:2],
            '<10'=apply(to.show.level.shootmasscom, 1, function(x){
              paste(x[3], '(', x[4], x[5],')' )}),
            '10-20'=apply(to.show.level.shootmasscom, 1, function(x){
              paste(x[6], '(', x[7], x[8],')' )}),
            '20-30'=apply(to.show.level.shootmasscom, 1, function(x){
              paste(x[9], '(', x[10], x[11],')' )}),
            '30-40'=apply(to.show.level.shootmasscom, 1, function(x){
              paste(x[12], '(', x[13], x[14],')' )}),
            '40-50'=apply(to.show.level.shootmasscom, 1, function(x){
              paste(x[15], '(', x[16], x[17],')' )}),
            '>50'=apply(to.show.level.shootmasscom, 1, function(x){
              paste(x[18], '(', x[19], x[20],')' )}))
          colnames(to.show.level.shootmasscom) <- c(paste('Application rate'), paste('Year'),
                                       paste('< 10'), paste('10 - 20'), paste('20 - 30')
                                       , paste('30 - 40'), paste('40 - 50'), paste('> 50'))
          
          store <- rGtkDataFrame(to.show.level.shootmasscom)
          view <- gtkTreeView(store)
          nms <- names(to.show.level.shootmasscom)
          QT <- sapply(1:ncol(to.show.level.shootmasscom), function(i) {
            type <- class(to.show.level.shootmasscom[,i])[1]
            view$addColumnWithType(name = nms[i], type, viewCol = i, storeCol = i)
          })
          levelTab$add(view)
          
          vboxhelp$packStart(label_level)
          vboxhelp$packStart(levelTab)
          levelFrame$add(vboxhelp)
          levelFrame$setTooltipText('IBC-grass simulates only the growing period of 30 weeks. Thus, one modelled year consists of 30 weeks.')
          gtkNotebookAppendPage(NotebookShootmass, levelFrame, tab.label=gtkLabel(paste('Application rate: ',level)))
        }
        
        vboxTabShootmass$packStart(NotebookShootmass)
        
        saveButton <-gtkButton('Save')
        saveButton$setTooltipText('Save the current tabs of this endpoints in a .txt file.')
        SaveDialog <- function(button){
          dialog <- gtkFileChooserDialog ( title = "Save a file" ,
                                           parent = w , action = "save" ,
                                           "gtk-ok" , GtkResponseType [ "ok" ] ,
                                           "gtk-cancel" , GtkResponseType [ "cancel" ] ,
                                           show = FALSE )
          color <-gdkColorToString('white')
          dialog$ModifyBg("normal", color)
          dialog$setCurrentName ("ShootmassCom.txt")
          gSignalConnect ( dialog , "response" ,
                           f = function ( dialog , response , data ) {
                             if ( response == GtkResponseType [ "ok" ] ) {
                               filename <- dialog$getFilename ( )
                               dev <- unlist(strsplit(filename, "[.]"))[2]
                               dev.ok <- "txt"
                               if (dev %in% dev.ok){
                                 write.table(to.show.shootmasscom, filename, sep="\t", row.names=F)
                               } else {
                                 dialog_tmp <- gtkMessageDialog(parent=dialog,
                                                                flags = "destroy-with-parent",
                                                                type="question" ,
                                                                buttons="ok" ,
                                                                "Please ensure that you save the table as 'txt'.")
                                 color <-gdkColorToString('white')
                                 dialog_tmp$ModifyBg("normal", color)
                                 gSignalConnect (dialog_tmp, "response", function(dialog_tmp, response, user.data){ dialog_tmp$Destroy()})
                                 
                               }
                             }
                             dialog$destroy ( )
                           } )
          
          dialog$run()
        }
        
        gSignalConnect(saveButton, signal = "clicked", SaveDialog)
        
        vboxTabShootmass$packStart(saveButton, fill=F)
        
        TabShootmass$add(vboxTabShootmass)
        
        # add popsize graphic frame to notebook
        gtkNotebookAppendPage(TableCom, TabShootmass, tab.label=gtkLabel("Shoot mass"))
      }
      
      if ("Diversity" %in% variable) {
        # initialize frame 
        TabDiversity <- gtkFrame()
        
        Diversity <- gtkNotebook()
        EvenessFrame <- gtkFrame()
        vboxEveness <- gtkVBox()
        SimpsonFrame <- gtkFrame()
        vboxSimpson <- gtkVBox()
        ShannonFrame <- gtkFrame()
        vboxShannon <- gtkVBox()
        SimpsonInvFrame <- gtkFrame()
        vboxSimpsonInv <- gtkVBox()
        
        to.show.eveness<-read.table("eveness_GRD.txt", header=T, sep="\t")
        to.show.simpson<-read.table("simpson_GRD.txt", header=T, sep="\t")
        to.show.shannon<-read.table("shannon_GRD.txt", header=T, sep="\t")
        to.show.simpsoninv<-read.table("simpsoninv_GRD.txt", header=T, sep="\t")
        
        to.show.eveness <- to.show.eveness[which(to.show.eveness$year %in% years.toshow),]
        to.show.simpson <- to.show.simpson[which(to.show.simpson$year %in% years.toshow),]
        to.show.shannon <- to.show.shannon[which(to.show.shannon$year %in% years.toshow),]
        to.show.simpsoninv <- to.show.simpsoninv[which(to.show.simpsoninv$year %in% years.toshow),]
        
        
        NotebookEveness <- gtkNotebook()
        for (level in levels(factor(to.show.eveness$Application.rate))){
          levelFrame <- gtkFrame()
          vboxhelp <- gtkVBoxNew()
          vboxhelp$setBorderWidth(5)
          # header
          label_level <- gtkLabel()
          label_level$setMarkup('<span weight=\"bold\" size=\"large\">The table shows the number of weeks in which the mean (minimum and maximum) effect 
on the eveness index is within a certain effect class</span> . 
<span size=\"large\">Only negative effects are considered. For positive effects have a look at the different graphics.
Please note that IBC-grass only simulations the growing period of 30 weeks. 
Thus, the maximal number of weeks can only be 30.
Eveness index is calculated as: - sum (p_i*log(p_i))/log(S) with s - number of PFTs, p_i - relative abundance of PFT i</span> ')
          label_level['height.request'] <- 100
          # the table to show
          levelTab <- gtkScrolledWindow()
          levelTab['height.request'] <- 300
          to.show.level.eveness <- to.show.eveness[to.show.eveness$Application.rate==level,]
          to.show.level.eveness<-data.frame(
            to.show.level.eveness[,1:2],
            '<10'=apply(to.show.level.eveness, 1, function(x){
              paste(x[3], '(', x[4], x[5],')' )}),
            '10-20'=apply(to.show.level.eveness, 1, function(x){
              paste(x[6], '(', x[7], x[8],')' )}),
            '20-30'=apply(to.show.level.eveness, 1, function(x){
              paste(x[9], '(', x[10], x[11],')' )}),
            '30-40'=apply(to.show.level.eveness, 1, function(x){
              paste(x[12], '(', x[13], x[14],')' )}),
            '40-50'=apply(to.show.level.eveness, 1, function(x){
              paste(x[15], '(', x[16], x[17],')' )}),
            '>50'=apply(to.show.level.eveness, 1, function(x){
              paste(x[18], '(', x[19], x[20],')' )}))
          colnames(to.show.level.eveness) <- c(paste('Application rate'), paste('Year'),
                                       paste('< 10'), paste('10 - 20'), paste('20 - 30')
                                       , paste('30 - 40'), paste('40 - 50'), paste('> 50'))
          
          store <- rGtkDataFrame(to.show.level.eveness)
          view <- gtkTreeView(store)
          nms <- names(to.show.level.eveness)
          QT <- sapply(1:ncol(to.show.level.eveness), function(i) {
            type <- class(to.show.level.eveness[,i])[1]
            view$addColumnWithType(name = nms[i], type, viewCol = i, storeCol = i)
          })
          levelTab$add(view)
          
          vboxhelp$packStart(label_level)
          vboxhelp$packStart(levelTab)
          levelFrame$add(vboxhelp)
          levelFrame$setTooltipText('IBC-grass simulates only the growing period of 30 weeks. Thus, one modelled year consists of 30 weeks.')
          gtkNotebookAppendPage(NotebookEveness, levelFrame, tab.label=gtkLabel(paste('Application rate: ',level)))
        }
        
        vboxEveness$packStart(NotebookEveness)
        
        saveButton <-gtkButton('Save')
        saveButton$setTooltipText('Save the current tabs of this endpoints in a .txt file.')
        SaveDialog <- function(button){
          dialog <- gtkFileChooserDialog ( title = "Save a file" ,
                                           parent = w , action = "save" ,
                                           "gtk-ok" , GtkResponseType [ "ok" ] ,
                                           "gtk-cancel" , GtkResponseType [ "cancel" ] ,
                                           show = FALSE )
          color <-gdkColorToString('white')
          dialog$ModifyBg("normal", color)
          dialog$setCurrentName ("Eveness.txt")
          gSignalConnect ( dialog , "response" ,
                           f = function ( dialog , response , data ) {
                             if ( response == GtkResponseType [ "ok" ] ) {
                               filename <- dialog$getFilename ( )
                               dev <- unlist(strsplit(filename, "[.]"))[2]
                               dev.ok <- "txt"
                               if (dev %in% dev.ok){
                                 write.table(to.show.eveness, filename, sep="\t", row.names=F)
                               } else {
                                 dialog_tmp <- gtkMessageDialog(parent=dialog,
                                                                flags = "destroy-with-parent",
                                                                type="question" ,
                                                                buttons="ok" ,
                                                                "Please ensure that you save the table as 'txt'.")
                                 color <-gdkColorToString('white')
                                 dialog_tmp$ModifyBg("normal", color)
                                 gSignalConnect (dialog_tmp, "response", function(dialog_tmp, response, user.data){ dialog_tmp$Destroy()})
                                 
                               }
                             }
                             dialog$destroy ( )
                           } )
          
          dialog$run()
        }
        
        gSignalConnect(saveButton, signal = "clicked", SaveDialog)
        
        vboxEveness$packStart(saveButton, fill=F)
        
        EvenessFrame$add(vboxEveness)
        
        NotebookShannon <- gtkNotebook()
        for (level in levels(factor(to.show.shannon$Application.rate))){
          levelFrame <- gtkFrame()
          vboxhelp <- gtkVBoxNew()
          vboxhelp$setBorderWidth(5)
          # header
          label_level <- gtkLabel()
          label_level$setMarkup('<span weight=\"bold\" size=\"large\">The table shows the number of weeks in which the mean (minimum and maximum) effect 
on the shannon index is within a certain effect class</span> . 
<span size=\"large\">Only negative effects are considered. For positive effects have a look at the different graphics.
Please note that IBC-grass only simulations the growing period of 30 weeks. 
Thus, the maximal number of weeks can only be 30.
Shannon index is calculated as: - sum (p_i*log(p_i))/log(S) with p_i - relative abundance of PFT i</span> ')
          label_level['height.request'] <- 100
          # the table to show
          levelTab <- gtkScrolledWindow()
          levelTab['height.request'] <- 300
          to.show.level.shannon <- to.show.shannon[to.show.shannon$Application.rate==level,]
          to.show.level.shannon<-data.frame(
            to.show.level.shannon[,1:2],
            '<10'=apply(to.show.level.shannon, 1, function(x){
              paste(x[3], '(', x[4], x[5],')' )}),
            '10-20'=apply(to.show.level.shannon, 1, function(x){
              paste(x[6], '(', x[7], x[8],')' )}),
            '20-30'=apply(to.show.level.shannon, 1, function(x){
              paste(x[9], '(', x[10], x[11],')' )}),
            '30-40'=apply(to.show.level.shannon, 1, function(x){
              paste(x[12], '(', x[13], x[14],')' )}),
            '40-50'=apply(to.show.level.shannon, 1, function(x){
              paste(x[15], '(', x[16], x[17],')' )}),
            '>50'=apply(to.show.level.shannon, 1, function(x){
              paste(x[18], '(', x[19], x[20],')' )}))
          colnames(to.show.level.shannon) <- c(paste('Application rate'), paste('Year'),
                                       paste('< 10'), paste('10 - 20'), paste('20 - 30')
                                       , paste('30 - 40'), paste('40 - 50'), paste('> 50'))
          
          store <- rGtkDataFrame(to.show.level.shannon)
          view <- gtkTreeView(store)
          nms <- names(to.show.level.shannon)
          QT <- sapply(1:ncol(to.show.level.shannon), function(i) {
            type <- class(to.show.level.shannon[,i])[1]
            view$addColumnWithType(name = nms[i], type, viewCol = i, storeCol = i)
          })
          levelTab$add(view)
          
          vboxhelp$packStart(label_level)
          vboxhelp$packStart(levelTab)
          levelFrame$add(vboxhelp)
          levelFrame$setTooltipText('IBC-grass simulates only the growing period of 30 weeks. Thus, one modelled year consists of 30 weeks.')
          gtkNotebookAppendPage(NotebookShannon, levelFrame, tab.label=gtkLabel(paste('Application rate: ',level)))
        }
        
        vboxShannon$packStart(NotebookShannon)
        
        saveButton <-gtkButton('Save')
        saveButton$setTooltipText('Save the current tabs of this endpoints in a .txt file.')
        SaveDialog <- function(button){
          dialog <- gtkFileChooserDialog ( title = "Save a file" ,
                                           parent = w , action = "save" ,
                                           "gtk-ok" , GtkResponseType [ "ok" ] ,
                                           "gtk-cancel" , GtkResponseType [ "cancel" ] ,
                                           show = FALSE )
          color <-gdkColorToString('white')
          dialog$ModifyBg("normal", color)
          dialog$setCurrentName ("Shannon.txt")
          gSignalConnect ( dialog , "response" ,
                           f = function ( dialog , response , data ) {
                             if ( response == GtkResponseType [ "ok" ] ) {
                               filename <- dialog$getFilename ( )
                               dev <- unlist(strsplit(filename, "[.]"))[2]
                               dev.ok <- "txt"
                               if (dev %in% dev.ok){
                                 write.table(to.show.shannon, filename, sep="\t", row.names=F)
                               } else {
                                 dialog_tmp <- gtkMessageDialog(parent=dialog,
                                                                flags = "destroy-with-parent",
                                                                type="question" ,
                                                                buttons="ok" ,
                                                                "Please ensure that you save the table as 'txt'.")
                                 color <-gdkColorToString('white')
                                 dialog_tmp$ModifyBg("normal", color)
                                 gSignalConnect (dialog_tmp, "response", function(dialog_tmp, response, user.data){ dialog_tmp$Destroy()})
                                 
                               }
                             }
                             dialog$destroy ( )
                           } )
          
          dialog$run()
        }
        
        gSignalConnect(saveButton, signal = "clicked", SaveDialog)
        
        vboxShannon$packStart(saveButton, fill=F)
        
        ShannonFrame$add(vboxShannon)
        
        NotebookSimpson <- gtkNotebook()
        for (level in levels(factor(to.show.simpson$Application.rate))){
          levelFrame <- gtkFrame()
          vboxhelp <- gtkVBoxNew()
          vboxhelp$setBorderWidth(5)
          # header
          label_level <- gtkLabel()
          label_level$setMarkup('<span weight=\"bold\" size=\"large\">The table shows the number of weeks in which the mean (minimum and maximum) effect 
on the simpson index is within a certain effect class</span> . 
<span size=\"large\">Only negative effects are considered. For positive effects have a look at the different graphics.
Please note that IBC-grass only simulations the growing period of 30 weeks. 
Thus, the maximal number of weeks can only be 30.
Simpson index is calculated as: 1-sum (p_i^2) with p_i - relative abundance of PFT i</span> ')
          label_level['height.request'] <- 100
          # the table to show
          levelTab <- gtkScrolledWindow()
          levelTab['height.request'] <- 300
          to.show.level.simpson <- to.show.simpson[to.show.simpson$Application.rate==level,]
          to.show.level.simpson<-data.frame(
            to.show.level.simpson[,1:2],
            '<10'=apply(to.show.level.simpson, 1, function(x){
              paste(x[3], '(', x[4], x[5],')' )}),
            '10-20'=apply(to.show.level.simpson, 1, function(x){
              paste(x[6], '(', x[7], x[8],')' )}),
            '20-30'=apply(to.show.level.simpson, 1, function(x){
              paste(x[9], '(', x[10], x[11],')' )}),
            '30-40'=apply(to.show.level.simpson, 1, function(x){
              paste(x[12], '(', x[13], x[14],')' )}),
            '40-50'=apply(to.show.level.simpson, 1, function(x){
              paste(x[15], '(', x[16], x[17],')' )}),
            '>50'=apply(to.show.level.simpson, 1, function(x){
              paste(x[18], '(', x[19], x[20],')' )}))
          colnames(to.show.level.simpson) <- c(paste('Application rate'), paste('Year'),
                                       paste('< 10'), paste('10 - 20'), paste('20 - 30')
                                       , paste('30 - 40'), paste('40 - 50'), paste('> 50'))
          
          store <- rGtkDataFrame(to.show.level.simpson)
          view <- gtkTreeView(store)
          nms <- names(to.show.level.simpson)
          QT <- sapply(1:ncol(to.show.level.simpson), function(i) {
            type <- class(to.show.level.simpson[,i])[1]
            view$addColumnWithType(name = nms[i], type, viewCol = i, storeCol = i)
          })
          levelTab$add(view)
          
          vboxhelp$packStart(label_level)
          vboxhelp$packStart(levelTab)
          levelFrame$add(vboxhelp)
          levelFrame$setTooltipText('IBC-grass simulates only the growing period of 30 weeks. Thus, one modelled year consists of 30 weeks.')
          gtkNotebookAppendPage(NotebookSimpson, levelFrame, tab.label=gtkLabel(paste('Application rate: ',level)))
        }
        
        vboxSimpson$packStart(NotebookSimpson)
        
        saveButton <-gtkButton('Save')
        saveButton$setTooltipText('Save the current tabs of this endpoints in a .txt file.')
        SaveDialog <- function(button){
          dialog <- gtkFileChooserDialog ( title = "Save a file" ,
                                           parent = w , action = "save" ,
                                           "gtk-ok" , GtkResponseType [ "ok" ] ,
                                           "gtk-cancel" , GtkResponseType [ "cancel" ] ,
                                           show = FALSE )
          color <-gdkColorToString('white')
          dialog$ModifyBg("normal", color)
          dialog$setCurrentName ("Simpson.txt")
          gSignalConnect ( dialog , "response" ,
                           f = function ( dialog , response , data ) {
                             if ( response == GtkResponseType [ "ok" ] ) {
                               filename <- dialog$getFilename ( )
                               dev <- unlist(strsplit(filename, "[.]"))[2]
                               dev.ok <- "txt"
                               if (dev %in% dev.ok){
                                 write.table(to.show.simpson, filename, sep="\t", row.names=F)
                               } else {
                                 dialog_tmp <- gtkMessageDialog(parent=dialog,
                                                                flags = "destroy-with-parent",
                                                                type="question" ,
                                                                buttons="ok" ,
                                                                "Please ensure that you save the table as 'txt'.")
                                 color <-gdkColorToString('white')
                                 dialog_tmp$ModifyBg("normal", color)
                                 gSignalConnect (dialog_tmp, "response", function(dialog_tmp, response, user.data){ dialog_tmp$Destroy()})
                                 
                               }
                             }
                             dialog$destroy ( )
                           } )
          
          dialog$run()
        }
        
        gSignalConnect(saveButton, signal = "clicked", SaveDialog)
        
        vboxSimpson$packStart(saveButton, fill=F)
        
        SimpsonFrame$add(vboxSimpson)
        
        NotebookSimpsonInv <- gtkNotebook()
        for (level in levels(factor(to.show.simpsoninv$Application.rate))){
          levelFrame <- gtkFrame()
          vboxhelp <- gtkVBoxNew()
          vboxhelp$setBorderWidth(5)
          # header
          label_level <- gtkLabel()
          label_level$setMarkup('<span weight=\"bold\" size=\"large\">The table shows the number of weeks in which the mean (minimum and maximum) effect 
on the inverse simpson index is within a certain effect class</span> . 
<span size=\"large\">Only negative effects are considered. For positive effects have a look at the different graphics.
Please note that IBC-grass only simulations the growing period of 30 weeks. 
Thus, the maximal number of weeks can only be 30.
Inverse Simpson index is calculated as: 1/sum (p_i^2) with p_i - relative abundance of PFT i</span> ')
          label_level['height.request'] <- 100
          # the table to show
          levelTab <- gtkScrolledWindow()
          levelTab['height.request'] <- 300
          to.show.level.simpsoninv <- to.show.simpsoninv[to.show.simpsoninv$Application.rate==level,]
          to.show.level.simpsoninv<-data.frame(
            to.show.level.simpsoninv[,1:2],
            '<10'=apply(to.show.level.simpsoninv, 1, function(x){
              paste(x[3], '(', x[4], x[5],')' )}),
            '10-20'=apply(to.show.level.simpsoninv, 1, function(x){
              paste(x[6], '(', x[7], x[8],')' )}),
            '20-30'=apply(to.show.level.simpsoninv, 1, function(x){
              paste(x[9], '(', x[10], x[11],')' )}),
            '30-40'=apply(to.show.level.simpsoninv, 1, function(x){
              paste(x[12], '(', x[13], x[14],')' )}),
            '40-50'=apply(to.show.level.simpsoninv, 1, function(x){
              paste(x[15], '(', x[16], x[17],')' )}),
            '>50'=apply(to.show.level.simpsoninv, 1, function(x){
              paste(x[18], '(', x[19], x[20],')' )}))
          colnames(to.show.level.simpsoninv) <- c(paste('Application rate'), paste('Year'),
                                       paste('< 10'), paste('10 - 20'), paste('20 - 30')
                                       , paste('30 - 40'), paste('40 - 50'), paste('> 50'))
          
          store <- rGtkDataFrame(to.show.level.simpsoninv)
          view <- gtkTreeView(store)
          nms <- names(to.show.level.simpsoninv)
          QT <- sapply(1:ncol(to.show.level.simpsoninv), function(i) {
            type <- class(to.show.level.simpsoninv[,i])[1]
            view$addColumnWithType(name = nms[i], type, viewCol = i, storeCol = i)
          })
          levelTab$add(view)
          
          vboxhelp$packStart(label_level)
          vboxhelp$packStart(levelTab)
          levelFrame$add(vboxhelp)
          levelFrame$setTooltipText('IBC-grass simulates only the growing period of 30 weeks. Thus, one modelled year consists of 30 weeks.')
          gtkNotebookAppendPage(NotebookSimpsonInv, levelFrame, tab.label=gtkLabel(paste('Application rate: ',level)))
        }
        
        vboxSimpsonInv$packStart(NotebookSimpsonInv)
        
        saveButton <-gtkButton('Save')
        saveButton$setTooltipText('Save the current tabs of this endpoints in a .txt file.')
        SaveDialog <- function(button){
          dialog <- gtkFileChooserDialog ( title = "Save a file" ,
                                           parent = w , action = "save" ,
                                           "gtk-ok" , GtkResponseType [ "ok" ] ,
                                           "gtk-cancel" , GtkResponseType [ "cancel" ] ,
                                           show = FALSE )
          color <-gdkColorToString('white')
          dialog$ModifyBg("normal", color)
          dialog$setCurrentName ("InvSimpson.txt")
          gSignalConnect ( dialog , "response" ,
                           f = function ( dialog , response , data ) {
                             if ( response == GtkResponseType [ "ok" ] ) {
                               filename <- dialog$getFilename ( )
                               dev <- unlist(strsplit(filename, "[.]"))[2]
                               dev.ok <- "txt"
                               if (dev %in% dev.ok){
                                 write.table(to.show.simpsoninv, filename, sep="\t", row.names=F)
                               } else {
                                 dialog_tmp <- gtkMessageDialog(parent=dialog,
                                                                flags = "destroy-with-parent",
                                                                type="question" ,
                                                                buttons="ok" ,
                                                                "Please ensure that you save the table as 'txt'.")
                                 color <-gdkColorToString('white')
                                 dialog_tmp$ModifyBg("normal", color)
                                 gSignalConnect (dialog_tmp, "response", function(dialog_tmp, response, user.data){ dialog_tmp$Destroy()})
                                 
                               }
                             }
                             dialog$destroy ( )
                           } )
          
          dialog$run()
        }
        
        gSignalConnect(saveButton, signal = "clicked", SaveDialog)
        
        vboxSimpsonInv$packStart(saveButton, fill=F)
        
        SimpsonInvFrame$add(vboxSimpsonInv)
        
        gtkNotebookAppendPage(Diversity, EvenessFrame, tab.label=gtkLabel("Eveness-Index"))
        gtkNotebookAppendPage(Diversity, ShannonFrame, tab.label=gtkLabel("Shannon-Index"))
        gtkNotebookAppendPage(Diversity, SimpsonFrame, tab.label=gtkLabel("Simpson-Index"))
        gtkNotebookAppendPage(Diversity, SimpsonInvFrame, tab.label=gtkLabel("Inverse Simpson-Index"))
        
        # 
        TabDiversity$add(Diversity)
        
        # add popsize graphic frame to notebook
        gtkNotebookAppendPage(TableCom, TabDiversity, tab.label=gtkLabel("Diversity Indices"))
        
      }
      
      outputComTable$add(TableCom)
    
      ShowTablesCom$label<-'Update tables'  
      } else{
        dialog <- gtkMessageDialog(parent=w,
                                   flags = "destroy-with-parent",
                                   type="question" ,
                                   buttons="ok" ,
                                   "Please ensure that you select at least one variable.")
        color <-gdkColorToString('white')
        dialog$ModifyBg("normal", color)
        gSignalConnect (dialog, "response", function(dialog, response, user.data){ dialog$Destroy()})
        }
      
    } else{
      dialog <- gtkMessageDialog(parent=w,
                                 flags = "destroy-with-parent",
                                 type="question" ,
                                 buttons="ok" ,
                                 "Please ensure that the first year you would like to show is smaller than the last year.")
      color <-gdkColorToString('white')
      dialog$ModifyBg("normal", color)
      gSignalConnect (dialog, "response", function(dialog, response, user.data){ dialog$Destroy()})
    }
  }
  ##################################################
  ### Community Tab
  ##################################################
  vboxCom <- gtkVBoxNew(homogeneous = F, spacing = 0)
  vboxCom$setBorderWidth(5)
    #####
    # parameters
    #####
    first_year <- min(effect.timestep.PFT[which(effect.timestep.PFT$period=="during"),]$year)
    last_year <- max(effect.timestep.PFT[which(effect.timestep.PFT$period=="during"),]$year)
    #####
    # labels
    #####
    label_years_Com <-gtkLabel()
    label_years_Com$setMarkup(paste('<span weight=\"bold\" size=\"large\">Which years should be analysed?</span> 
[herbicide application period: ', first_year, ' - ', last_year, ']', sep=""))
    label_years_Com$setTooltipText('If you select more than 5 years, the mean over each year is plotted.')
    label_first <-gtkLabel()
    label_first$setMarkup('first year')
    label_last <-gtkLabel('last year')
    label_VARs_Com <-gtkLabel()
    label_VARs_Com$setMarkup('<span weight=\"bold\" size=\"large\">Which variables should be analysed?</span>')
    #####
    # sliders
    #####
    StartYearSliderCom <- gtkHScale(min = 1, max = max(as.numeric(years)), step = 1)
    EndYearSliderCom <- gtkHScale(min = 1, max = max(as.numeric(years)), step = 1)
    #####
    # variables
    #####
    vboxVariables<-gtkVBoxNew()
    check_buttons_var <- NULL
    for (variable in variables.GRD){
      checkbutton_var <- gtkCheckButton(variable)
      checkbutton_var$name=variable
      vboxVariables$packStart(checkbutton_var)
    }
    #####
    # Buttons
    #####
    ShowGraphicsCom <-gtkButton('Show Graphics')
    ShowGraphicsCom$setTooltipText('Graphics with the selected settings will be shown on the right sight under the tab graphics.')
    # ShowGraphicsCom['height.request'] <- 20
    gSignalConnect(ShowGraphicsCom, signal = "clicked", ShowGraphicsComFct)

    ShowTablesCom <-gtkButton('Show Tables')
    ShowTablesCom$setTooltipText('Tables will be shown on the right site summarising the number of weeks per year, in which the minimal, mean and maximal effects are within a certain effect range for the selected period.')
    # ShowTablesCom['height.request'] <- 20
    gSignalConnect(ShowTablesCom, signal = "clicked", ShowTablesComFct)
    #####
    # packing
    #####
    vboxwithhbox1Com <- gtkVBoxNew() 
    vboxwithhbox1Com$packStart(label_years_Com, expand=F, padding=5)
    hbox1 <- gtkHBoxNew()
    vboxinhbox1 <- gtkVBoxNew(spacing = 5)
    vboxinhbox1$packStart(StartYearSliderCom)
    vboxinhbox1$packStart(label_first)
    vboxinhbox2 <- gtkVBoxNew(spacing = 5)
    vboxinhbox2$packStart(EndYearSliderCom)
    vboxinhbox2$packStart(label_last)
    hbox1$packStart(vboxinhbox1)
    hbox1$packStart(vboxinhbox2)
    vboxwithhbox1Com$packStart(hbox1, expand=F, padding=5)
    vboxCom$packStart(vboxwithhbox1Com)
    #
    vbox1.1 <- gtkVBoxNew()
    # vbox1.1$setBorderWidth(5)
    vbox1.1$packStart(label_VARs_Com, expand=F, padding=5)
    vbox1.1$packStart(vboxVariables, expand=F, padding=5)
    vboxCom$packStart(vbox1.1)
    #
    vbox1.2 <- gtkVBoxNew()
    # vbox1.2$setBorderWidth(5)
    vbox1.2$packStart(ShowGraphicsCom, fill=F, expand=F, padding=5)
    vbox1.2$packStart(ShowTablesCom, fill=F, expand=F, padding=5)
    vboxCom$packStart(vbox1.2)
  
  ##################################################
  ###Population Tab
  ##################################################
  vboxPop <- gtkVBoxNew(homogeneous = F)
  vboxPop$setBorderWidth(5)
    #####
    # labels
    #####
    label_years_Pop <-gtkLabel()
    label_years_Pop$setMarkup(paste('<span weight=\"bold\" size=\"large\">Which years should be analysed?</span> 
[herbicide application period: ', first_year, ' - ', last_year, ']', sep=""))
    label_years_Pop$setTooltipText('If you select more than 5 years, the mean over each year is plotted.')
    label_first <-gtkLabel()
    label_first$setMarkup('first year')
    label_last <-gtkLabel('last year')
    label_VARs_Pop <-gtkLabel()
    label_VARs_Pop$setMarkup('<span weight=\"bold\" size=\"large\">Which variables should be analysed?</span>')
    label_PFTs_Pop <-gtkLabel()
    label_PFTs_Pop$setMarkup('<span weight=\"bold\" size=\"large\">Which PFTs should be analysed?</span>')
    #####
    # sliders
    #####
    StartYearSliderPop <- gtkHScale(min = 1, max = max(as.numeric(years)), step = 1)
    EndYearSliderPop <- gtkHScale(min = 1, max = max(as.numeric(years)), step = 1)
    #####
    # PFTs
    #####
    scrolledPFT<-gtkScrolledWindow()
    scrolledPFT['height.request'] <- 200
    scrolledPFT$setPolicy("automatic","automatic")
    vboxPFTs<-gtkVBoxNew()
    check_buttons <- NULL
    for (PFT in PFTs){
      checkbutton <- gtkCheckButton(PFT)
      checkbutton$name=PFT
      lookuptable <- get("PFTtoSpecies", envir=IBCvariables)
      Species <- lookuptable[which(lookuptable$Species == PFT),2]
      markup <- paste("<b>e.g. </b> <i>", Species,"</i>", sep=" ")
      checkbutton$setTooltipMarkup(markup)
      vboxPFTs$packStart(checkbutton)
    }
    scrolledPFT$addWithViewport(vboxPFTs)
    #####
    # variables
    #####
    vboxVariablesPop<-gtkVBoxNew()
    check_buttons_var <- NULL
    for (variable in variables.PFT){
      checkbutton_var <- gtkCheckButton(variable)
      checkbutton_var$name=variable
      vboxVariablesPop$packStart(checkbutton_var)
    }
    #####
    # Buttons
    #####
    ShowGraphicsPop <-gtkButton('Show Graphics')
    ShowGraphicsPop$setTooltipText('Graphics with the selected settings will be shown on the right sight under the tab graphics.')
    # ShowGraphicsPop['height.request'] <- 20
    gSignalConnect(ShowGraphicsPop, signal = "clicked", ShowGraphicsPopFct)
    
    ShowTablesPop <-gtkButton('Show Tables')  
    ShowTablesPop$setTooltipText('Tables will be shown on the right site summarising the number of weeks per year, in which the minimal, mean and maximal effects are within a certain effect range for the selected period and PFTs.')
    # ShowTablesPop['height.request'] <- 20
    gSignalConnect(ShowTablesPop, signal = "clicked", ShowTablesPopFct)
    #####
    # packing
    #####
    vboxwithhbox1 <- gtkVBoxNew() 
    vboxwithhbox1$packStart(label_years_Pop, padding=5)
    hbox1Pop <- gtkHBoxNew()
    vboxinhbox1Pop <- gtkVBoxNew()
    vboxinhbox1Pop$packStart(StartYearSliderPop)
    vboxinhbox1Pop$packStart(label_first)
    vboxinhbox2Pop <- gtkVBoxNew()
    vboxinhbox2Pop$packStart(EndYearSliderPop)
    vboxinhbox2Pop$packStart(label_last)
    hbox1Pop$packStart(vboxinhbox1Pop)
    hbox1Pop$packStart(vboxinhbox2Pop)
    vboxwithhbox1$packStart(hbox1Pop, padding=5)
    vboxPop$packStart(vboxwithhbox1)
    #
    vbox1.1Pop <- gtkVBoxNew()
    # vbox1.1Pop$setBorderWidth(5)
    vbox1.1Pop$packStart(label_PFTs_Pop, padding=5)
    # vboxPFTs$setBorderWidth(10)
    vbox1.1Pop$packStart(scrolledPFT)
    vboxPop$packStart(vbox1.1Pop)
    #
    vbox2.1Pop <- gtkVBoxNew()
    # vbox2.1Pop$setBorderWidth(5)
    vbox2.1Pop$packStart(label_VARs_Pop, padding=5)
    # vboxVariablesPop$setBorderWidth(10)
    vbox2.1Pop$packStart(vboxVariablesPop)
    vboxPop$packStart(vbox2.1Pop)
    #
    vbox1.2Pop <- gtkVBoxNew()
    # vbox1.2Pop$setBorderWidth(5)
    vbox1.2Pop$packStart(ShowGraphicsPop, fill=F)
    vbox1.2Pop$packStart(ShowTablesPop, fill=F)
    vboxPop$packStart(vbox1.2Pop)

  ##################################################
  ### Close Button
  ##################################################
  CloseButton <-gtkButton('Close Project')
  CloseButton$setTooltipText('Close the current project. If you did a new simulation and want to keep the analyses, you will be asked to save it!')
  Close <- function(button){
    if (unlist(strsplit(getwd(),"/"))[length(unlist(strsplit(getwd(),"/")))]=="currentSimulation"){
      w_help<-gtkWindow(show=F)
      w_help$setPosition('GTK_WIN_POS_CENTER')
      color <-gdkColorToString('white')
      w_help$ModifyBg("normal", color)
      vbox<-gtkVBoxNew(spacing=10)
      question <- gtkLabel('Do you want to save the current project?')
      # question$setBorderWidth(10)
      vbox$packStart(question, expand=F, fill=F)
      explanation <- gtkLabel('If you save the current project, you are able to rerun the analyses at a later time. 
                              Otherwise the current simulation files will be deleted.')
      # explanation$setBorderWidth(10)
      vbox$packStart(explanation, expand=F, fill=F)
      hbox <- gtkHBoxNew(homogeneous = T)
      
      ClickOnYes <- function(button){
        # select location to save to if currently in 'currentSimulation' folder
        dialog <- gtkFileChooserDialog ( title = "Save the project" ,
                                         parent = w , action = "select-folder" ,
                                         "gtk-ok" , GtkResponseType [ "ok" ] ,
                                         "gtk-cancel" , GtkResponseType [ "cancel" ] ,
                                         show = FALSE )
        color <-gdkColorToString('white')
        dialog$ModifyBg("normal", color)
        gSignalConnect ( dialog , "response" ,
                         f = function ( dialog , response , data ) {
                           if ( response == GtkResponseType [ "ok" ] ) {
                             # copy all files to that location
                             filename <- dialog$getFilename ( )
                             print(filename)
                             dir.create(filename)
                             files.to.copy <- list.files(getwd(), pattern=".txt")
                             files.to.copy <- files.to.copy[files.to.copy!="resultsPFT.txt" & files.to.copy!="resultsGRD.txt"]
                             if (CheckButton$getActive()==T) files.to.copy <- c(files.to.copy, list.dirs())
                             else files.to.copy <- c(files.to.copy, "./HerbicideSettings")
                             copy<-file.copy(files.to.copy, filename, recursive=TRUE)
                             # delete the current simulation files if copying is fine
                             if (all(copy)==T) unlink(list.files(getwd()), recursive=TRUE)   
                             setwd('..')
                             dialog$destroy ( )
                             w_help$destroy()
                             w$destroy()
                             Welcomefct()
                           }
                           if ( response == GtkResponseType [ "cancel" ] ) {
                             dialog$destroy ( )
                             w_help$destroy()
                           }
                           
                         } )
        dialog$run()
      }
      
      ClickOnNo <- function(button){
        w_no <- gtkWindow(show=F)
        w_no$setPosition('GTK_WIN_POS_CENTER')
        color <-gdkColorToString('white')
        w_no$ModifyBg("normal", color)
        vbox<-gtkVBox()
        warning<-gtkLabel('You are about to delete the current project incl. all simulation files. 
                          Do you want to continue?')
        vbox$packStart(warning)
        hbox <- gtkHBox(homogeneous = F)
        
        # button yes
        YesButton <- gtkButton('Yes')
        hbox$packStart(YesButton, fill=T, expand=T)
        ClickOnYes <- function(button){
          w_no$destroy()
          w_help$destroy()
          unlink(list.files(getwd()), recursive=TRUE) 
          w$destroy()
          setwd('..')
          Welcomefct()
        }
        
        # button cancel
        CancelButton <- gtkButton('Cancel')
        hbox$packStart(CancelButton, fill=T, expand=T)
        ClickOnCancel <- function(button){
          w_no$destroy()
        }
        
        vbox$packStart(hbox, fill=T, expand=F)
        w_no$add(vbox)
        w_no$show()
        
        gSignalConnect(YesButton, "clicked", ClickOnYes)
        gSignalConnect(CancelButton, "clicked", ClickOnCancel)
        
        
      }
      
      ClickOnCancel <- function(button){
        w_help$destroy()
      }
      
      vbox_help <- gtkVBoxNew()
      # add checkbutton keep original files
      CheckButton <- gtkCheckButton('Save raw data')
      vbox_help$packStart(CheckButton)
      YesButton <- gtkButton("Yes")
      vbox_help$packStart(YesButton)
      hbox$packStart(vbox_help, fill=T, expand=F)
      NoButton <- gtkButton("No")
      hbox$packStart(NoButton, fill=T, expand=F)
      CancelButton <- gtkButton("Cancel")
      hbox$packStart(CancelButton, fill=T, expand=F)
      vbox$packStart(hbox, fill=T, expand=F)
      w_help$add(vbox)
      w_help$show()
      
      gSignalConnect(YesButton, "clicked", ClickOnYes)
      gSignalConnect(NoButton, "clicked", ClickOnNo)
      gSignalConnect(CancelButton, "clicked", ClickOnCancel)
      
    }
    else {
      setwd(get('origWD', envir=IBCvariables))
      w$destroy()
      Welcomefct()
    }
  }
  
  gSignalConnect(CloseButton, signal = "clicked", Close)
  ##################################################
  ### Save Project Button
  ##################################################
  SaveProjectButton <-gtkButton('Save Project')
  SaveProjectButton$setTooltipText('Save the current project if you did a new simulation and want to keep the analyses.')
  SaveProject <- function(button){
    w_help<-gtkWindow(show=F)
    w_help$setPosition('GTK_WIN_POS_CENTER')
    color <-gdkColorToString('white')
    w_help$ModifyBg("normal", color)
    vbox<-gtkVBoxNew(spacing=10)
    question <- gtkLabel('Do you want to save also the raw data of the current project?')
    vbox$packStart(question, expand=F, fill=F)
    hbox <- gtkHBoxNew(homogeneous = T)
    
    ClickOnYes <- function(button){
      w_help$destroy()
      # select location to save to if currently in 'currentSimulation' folder
      dialog <- gtkFileChooserDialog ( title = "Save the project" ,
                                       parent = w , action = "select-folder" ,
                                       "gtk-ok" , GtkResponseType [ "ok" ] ,
                                       "gtk-cancel" , GtkResponseType [ "cancel" ] ,
                                       show = FALSE )
      color <-gdkColorToString('white')
      dialog$ModifyBg("normal", color)
      gSignalConnect ( dialog , "response" ,
                       f = function ( dialog , response , data ) {
                         if ( response == GtkResponseType [ "ok" ] ) {
                           # copy all files to that location
                           filename <- dialog$getFilename ( )
                           print(filename)
                           dir.create(filename)
                           files.to.copy <- list.files(getwd(), pattern=".txt")
                           files.to.copy <- files.to.copy[files.to.copy!="resultsPFT.txt" & files.to.copy!="resultsGRD.txt"]
                           files.to.copy <- c(files.to.copy, list.dirs())
                           copy<-file.copy(files.to.copy, filename, recursive=TRUE)
                           # delete the current simulation files if copying is fine
                           if (all(copy)==T) unlink(list.files(getwd()), recursive=TRUE)   
                           setwd('..')
                           dialog$destroy ( )
                           w$destroy()
                           Welcomefct()
                         }
                         if ( response == GtkResponseType [ "cancel" ] ) {
                           dialog$destroy ( )
                         }
                         
                       } )
      dialog$run()
    }
    
    ClickOnNo <- function(button){
      w_help$destroy()
      # select location to save to if currently in 'currentSimulation' folder
      dialog <- gtkFileChooserDialog ( title = "Save the project" ,
                                       parent = w , action = "select-folder" ,
                                       "gtk-ok" , GtkResponseType [ "ok" ] ,
                                       "gtk-cancel" , GtkResponseType [ "cancel" ] ,
                                       show = FALSE )
      color <-gdkColorToString('white')
      dialog$ModifyBg("normal", color)
      gSignalConnect ( dialog , "response" ,
                       f = function ( dialog , response , data ) {
                         if ( response == GtkResponseType [ "ok" ] ) {
                           # copy all files to that location
                           filename <- dialog$getFilename ( )
                           print(filename)
                           dir.create(filename)
                           files.to.copy <- list.files(getwd(), pattern=".txt")
                           files.to.copy <- files.to.copy[files.to.copy!="resultsPFT.txt" & files.to.copy!="resultsGRD.txt"]
                           files.to.copy <- c(files.to.copy, "./HerbicideSettings")
                           copy<-file.copy(files.to.copy, filename, recursive=TRUE)
                           # delete the current simulation files if copying is fine
                           if (all(copy)==T) unlink(list.files(getwd()), recursive=TRUE)   
                           setwd('..')
                           dialog$destroy ( )
                           w$destroy()
                           Welcomefct()
                         }
                         if ( response == GtkResponseType [ "cancel" ] ) {
                           dialog$destroy ( )
                         }
                         
                       } )
      dialog$run()
    }
    
    ClickOnCancel <- function(button){
      w_help$destroy()
    }
    
    YesButton <- gtkButton("Yes")
    hbox$packStart(YesButton, fill=T, expand=F)
    NoButton <- gtkButton("No")
    hbox$packStart(NoButton, fill=T, expand=F)
    CancelButton <- gtkButton("Cancel")
    hbox$packStart(CancelButton, fill=T, expand=F)
    vbox$packStart(hbox, fill=T, expand=F)
    w_help$add(vbox)
    w_help$show()
    
    gSignalConnect(YesButton, "clicked", ClickOnYes)
    gSignalConnect(NoButton, "clicked", ClickOnNo)
    gSignalConnect(CancelButton, "clicked", ClickOnCancel)
  }
  
  gSignalConnect(SaveProjectButton, signal = "clicked", SaveProject)
  ##################################################
  ### Put it all together
  ##################################################
  hboxCom<-gtkHBoxNew()
  hboxCom$packStart(vboxCom)
  outputComTable <- gtkFrame()
  outputComGraphics <- gtkFrame()
  outputCom<-gtkNotebook()
  gtkNotebookAppendPage(outputCom, outputComTable, tab.label=gtkLabel("Tables"))
  gtkNotebookAppendPage(outputCom, outputComGraphics, tab.label=gtkLabel("Graphics"))
  hboxCom$packStart(outputCom)
  nbCom <- gtkFrame()
  nbCom$add(hboxCom)
  
  hboxPop<-gtkHBoxNew()
  hboxPop$packStart(vboxPop)
  outputPopTable <- gtkFrame()
  outputPopGraphics <- gtkFrame()
  outputPop<-gtkNotebook()
  gtkNotebookAppendPage(outputPop, outputPopTable, tab.label=gtkLabel("Tables"))
  gtkNotebookAppendPage(outputPop, outputPopGraphics, tab.label=gtkLabel("Graphics"))
  hboxPop$packStart(outputPop)
  nbPop <- gtkFrame()
  nbPop$add(hboxPop)
  
  vbox <- gtkVBox()
  # vbox$setBorderWidth(10)
  nb <- gtkNotebook()
  gtkNotebookAppendPage(nb, nbCom, tab.label=gtkLabel("Community-level"))
  gtkNotebookAppendPage(nb, nbPop, tab.label=gtkLabel("Population-level"))
  vbox$packStart(vbox1)
  vbox$packStart(nb)
  vbox$packStart(SaveProjectButton)
  vbox$packStart(CloseButton)
  
  w <- gtkWindow(show=F)
  w$setPosition('GTK_WIN_POS_CENTER')
  w["title"] <- "IBC-grass GUI"
  color <-gdkColorToString('white')
  w$ModifyBg("normal", color)
  w$add(vbox)
  w$show()
}
