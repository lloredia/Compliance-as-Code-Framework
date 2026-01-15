#!/usr/bin/env python3
"""
Prowler Results Analyzer
Parses and analyzes Prowler compliance scan results
"""

import json
import sys
from pathlib import Path
from collections import defaultdict
from datetime import datetime

def load_prowler_results(filepath):
    """Load Prowler JSON results"""
    with open(filepath, 'r') as f:
        return json.load(f)

def analyze_results(data):
    """Analyze Prowler scan results"""
    stats = {
        'total': len(data),
        'pass': 0,
        'fail': 0,
        'info': 0,
        'by_severity': defaultdict(int),
        'by_service': defaultdict(lambda: {'pass': 0, 'fail': 0}),
        'critical_failures': [],
        'high_failures': []
    }
    
    for finding in data:
        status = finding.get('Status', 'unknown')
        severity = finding.get('Severity', 'unknown')
        service = finding.get('ServiceName', 'unknown')
        
        # Count by status
        if status == 'PASS':
            stats['pass'] += 1
            stats['by_service'][service]['pass'] += 1
        elif status == 'FAIL':
            stats['fail'] += 1
            stats['by_service'][service]['fail'] += 1
            stats['by_severity'][severity] += 1
            
            # Collect critical/high severity failures
            if severity == 'critical':
                stats['critical_failures'].append(finding)
            elif severity == 'high':
                stats['high_failures'].append(finding)
        elif status == 'INFO':
            stats['info'] += 1
    
    return stats

def print_summary(stats):
    """Print summary statistics"""
    print("\n" + "="*60)
    print("PROWLER COMPLIANCE SCAN SUMMARY")
    print("="*60)
    
    print(f"\n📊 Overall Results:")
    print(f"  Total Checks: {stats['total']}")
    print(f"  ✅ Passed: {stats['pass']} ({stats['pass']/stats['total']*100:.1f}%)")
    print(f"  ❌ Failed: {stats['fail']} ({stats['fail']/stats['total']*100:.1f}%)")
    print(f"  ℹ️  Manual: {stats['info']}")
    
    print(f"\n🔥 Severity Breakdown (Failures Only):")
    for severity in ['critical', 'high', 'medium', 'low']:
        count = stats['by_severity'].get(severity, 0)
        if count > 0:
            emoji = {'critical': '🔴', 'high': '🟠', 'medium': '🟡', 'low': '🔵'}
            print(f"  {emoji[severity]} {severity.upper()}: {count}")
    
    print(f"\n🎯 Top 10 Services by Failure Count:")
    sorted_services = sorted(
        stats['by_service'].items(),
        key=lambda x: x[1]['fail'],
        reverse=True
    )[:10]
    
    for service, counts in sorted_services:
        if counts['fail'] > 0:
            print(f"  {service:20s}: {counts['fail']:3d} failures, {counts['pass']:3d} passes")
    
    # Print critical failures
    if stats['critical_failures']:
        print(f"\n🚨 CRITICAL FAILURES ({len(stats['critical_failures'])}):")
        for finding in stats['critical_failures'][:5]:
            print(f"\n  • {finding.get('CheckTitle')}")
            print(f"    Service: {finding.get('ServiceName')}")
            print(f"    Details: {finding.get('StatusExtended')[:80]}...")
    
    # Print sample high failures
    if stats['high_failures']:
        print(f"\n⚠️  HIGH SEVERITY FAILURES (showing 5 of {len(stats['high_failures'])}):")
        for finding in stats['high_failures'][:5]:
            print(f"\n  • {finding.get('CheckTitle')}")
            print(f"    Service: {finding.get('ServiceName')}")

def compare_results(before_file, after_file):
    """Compare two Prowler scan results"""
    print("\n" + "="*60)
    print("COMPLIANCE IMPROVEMENT ANALYSIS")
    print("="*60)
    
    before_data = load_prowler_results(before_file)
    after_data = load_prowler_results(after_file)
    
    before_stats = analyze_results(before_data)
    after_stats = analyze_results(after_data)
    
    # Calculate improvements
    pass_improvement = after_stats['pass'] - before_stats['pass']
    fail_improvement = before_stats['fail'] - after_stats['fail']
    
    print(f"\n📈 Overall Improvement:")
    print(f"  Before: {before_stats['pass']}/{before_stats['total']} passed ({before_stats['pass']/before_stats['total']*100:.1f}%)")
    print(f"  After:  {after_stats['pass']}/{after_stats['total']} passed ({after_stats['pass']/after_stats['total']*100:.1f}%)")
    print(f"  Change: {'+' if pass_improvement > 0 else ''}{pass_improvement} checks fixed")
    
    print(f"\n🎯 Severity Changes:")
    for severity in ['critical', 'high', 'medium', 'low']:
        before_count = before_stats['by_severity'].get(severity, 0)
        after_count = after_stats['by_severity'].get(severity, 0)
        change = after_count - before_count
        
        if before_count > 0 or after_count > 0:
            emoji = {'critical': '🔴', 'high': '🟠', 'medium': '🟡', 'low': '🔵'}
            change_str = f"{'+' if change > 0 else ''}{change}"
            print(f"  {emoji[severity]} {severity.upper():8s}: {before_count:3d} → {after_count:3d} ({change_str})")

def main():
    """Main function"""
    import argparse
    
    parser = argparse.ArgumentParser(description='Analyze Prowler compliance scan results')
    parser.add_argument('file', nargs='?', help='Path to Prowler JSON output file')
    parser.add_argument('--compare', action='store_true', help='Compare two scan results')
    parser.add_argument('--before', help='Before scan file (for comparison)')
    parser.add_argument('--after', help='After scan file (for comparison)')
    
    args = parser.parse_args()
    
    if args.compare:
        if not args.before or not args.after:
            print("Error: --compare requires --before and --after files")
            sys.exit(1)
        compare_results(args.before, args.after)
    elif args.file:
        data = load_prowler_results(args.file)
        stats = analyze_results(data)
        print_summary(stats)
    else:
        # Try to find most recent Prowler output
        prowler_files = list(Path('.').glob('prowler-output-*.json'))
        if prowler_files:
            latest = max(prowler_files, key=lambda p: p.stat().st_mtime)
            print(f"📁 Using most recent scan: {latest}")
            data = load_prowler_results(latest)
            stats = analyze_results(data)
            print_summary(stats)
        else:
            print("Error: No Prowler output file specified and none found in current directory")
            parser.print_help()
            sys.exit(1)

if __name__ == '__main__':
    main()
