package com.example.springboot.config;

import org.apache.lucene.analysis.Analyzer;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.wltea.analyzer.lucene.IKAnalyzer;

@Configuration
public class IkAnalyzerConfig {

    @Bean
    public Analyzer ikAnalyzer() {
        return new IKAnalyzer(true);
    }

}