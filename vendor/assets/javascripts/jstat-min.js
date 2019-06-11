/**
 * jStat - JavaScript Statistical Library
 * Copyright (c) 2011
 * This document is licensed as free software under the terms of the
 * MIT License: http://www.opensource.org/licenses/mit-license.php */this.j$=this.jStat=function(a,b){function i(){return new i.fn.init(arguments)}var c=Array.prototype.slice,d=Object.prototype.toString,e=function(a,b){return a-b},f=function(b,c){var d=b>c?b:c;return a.pow(10,17-~~(a.log(d>0?d:-d)*a.LOG10E))},g=Array.isArray||function(a){return d.call(a)==="[object Array]"},h=function(a){return d.call(a)==="[object Function]"};i.fn=i.prototype={constructor:i,init:function(a){if(g(a[0]))if(g(a[0][0])){for(var b=0;b<a[0].length;b++)this[b]=a[0][b];this.length=a[0].length}else this[0]=a[0],this.length=1;else isNaN(a[0])||(this[0]=i.seq.apply(null,a),this.length=1);return this},length:0,toArray:function(){return this.length>1?c.call(this):c.call(this)[0]},push:[].push,sort:[].sort,splice:[].splice},i.fn.init.prototype=i.fn,i.utils={calcRdx:f,isArray:g,isFunction:h},i.extend=function(a){var b=c.call(arguments),d=1,e;if(b.length===1){for(e in a)i[e]=a[e];return this}for(;d<b.length;d++)for(e in b[d])a[e]=b[d][e];return a},i.extend({transpose:function(a){g(a[0])||(a=[a]);var b=a.length,c=a[0].length,d=[],e=0,f;for(;e<c;e++){d.push([]);for(f=0;f<b;f++)d[e].push(a[f][e])}return d},map:function(a,b,c){g(a[0])||(a=[a]);var d=0,e=a.length,f=a[0].length,h=c?a:[],i;for(;d<e;d++){h[d]||(h[d]=[]);for(i=0;i<f;i++)h[d][i]=b(a[d][i],d,i)}return h.length===1?h[0]:h},alter:function(a,b){return i.map(a,b,!0)},create:function(a,b,c){h(b)&&(c=b,b=a);var d=[],e,f;for(e=0;e<a;e++){d[e]=[];for(f=0;f<b;f++)d[e].push(c(e,f))}return d},zeros:function(a,b){isNaN(b)&&(b=a);return i.create(a,b,function(){return 0})},ones:function(a,b){isNaN(b)&&(b=a);return i.create(a,b,function(){return 1})},rand:function(b,c){isNaN(c)&&(c=b);return i.create(b,c,function(){return a.random()})},identity:function(a,b){isNaN(b)&&(b=a);return i.create(a,b,function(a,b){return a===b?1:0})},seq:function(a,b,c,d){h(d)||(d=!1);var e=[],g=f(a,b),i=(b*g-a*g)/((c-1)*g),j=a,k=0;for(;j<=b;k++,j=(a*g+i*g*k)/g)e.push(d?d(j,k):j);return e},add:function(a,b){if(g(b)){g(b[0])||(b=[b]);return i.map(a,function(a,c,d){return a+b[c][d]})}return i.map(a,function(a){return a+b})},divide:function(a,b){return g(b)?!1:i.map(a,function(a){return a/b})},multiply:function(a,b){var c,d,e,f,h=a.length,j=a[0].length,k=i.zeros(h,e=isNaN(b)?b[0].length:j),l=0;if(g(b)){for(;l<e;l++)for(c=0;c<h;c++){f=0;for(d=0;d<j;d++)f+=a[c][d]*b[d][l];k[c][l]=f}return h===1&&l===1?k[0][0]:k}return i.map(a,function(a){return a*b})},subtract:function(a,b){if(g(b)){g(b[0])||(b=[b]);return i.map(a,function(a,c,d){return a-b[c][d]||0})}return i.map(a,function(a){return a-b})},dot:function(a,b){g(a[0])||(a=[a]),g(b[0])||(b=[b]);var c=a[0].length===1&&a.length!==1?i.transpose(a):a,d=b[0].length===1&&b.length!==1?i.transpose(b):b,e=[],f=0,h=c.length,j=c[0].length,k,l;for(;f<h;f++){e[f]=[],k=0;for(l=0;l<j;l++)k+=c[f][l]*d[f][l];e[f]=k}return e.length===1?e[0]:e},pow:function(b,c){return i.map(b,function(b){return a.pow(b,c)})},abs:function(b){return i.map(b,function(b){return a.abs(b)})},clear:function(a){return i.alter(a,function(){return 0})},norm:function(b,c){var d=0,e=0;isNaN(c)&&(c=2),g(b[0])&&(b=b[0]);for(;e<b.length;e++)d+=a.pow(a.abs(b[e]),c);return a.pow(d,1/c)},angle:function(b,c){return a.acos(i.dot(b,c)/(i.norm(b)*i.norm(c)))},symmetric:function(a){var b=!0,c=0,d=a.length,e;if(a.length!==a[0].length)return!1;for(;c<d;c++)for(e=0;e<d;e++)if(a[e][c]!==a[c][e])return!1;return!0},sum:function(a){var b=0,c=a.length,d;while(--c>=0)d=f(b,a[c]),b=(b*d+a[c]*d)/d;return b},sumsqrd:function(a){var b=0,c=a.length;while(--c>=0)b+=a[c]*a[c];return b},sumsqerr:function(b){var c=i.mean(b),d=0,e=b.length;while(--e>=0)d+=a.pow(b[e]-c,2);return d},product:function(a){var b=1,c=a.length;while(--c>=0)b*=a[c];return b},min:function(a){var b=a[0],c=0;while(++c<a.length)a[c]<b&&(b=a[c]);return b},max:function(a){var b=a[0],c=0;while(++c<a.length)a[c]>b&&(b=a[c]);return b},mean:function(a){return i.sum(a)/a.length},meansqerr:function(a){return i.sumsqerr(a)/a.length},geomean:function(b){return a.pow(i.product(b),1/b.length)},median:function(a){var b=a.length,c=a.slice().sort(e);return b&1?c[b/2|0]:(c[b/2-1]+c[b/2])/2},cumsum:function(a){var b=[a[0]],c=a.length,d=1;for(;d<c;d++)b.push(b[d-1]+a[d]);return b},diff:function(a){var b=[],c=a.length,d=1;for(d=1;d<c;d++)b.push(a[d]-a[d-1]);return b},mode:function(a){var b=a.length,c=a.slice().sort(e),d=1,f=0,g=0,h=0,i;for(;h<b;h++)c[h]===c[h+1]?d++:d>f?(i=c[h],f=d,d=1,g=0):d===f?g++:d=1;return g===0?i:!1},range:function(a){var b=a.slice().sort(e);return b[b.length-1]-b[0]},variance:function(b,c){var d=i.mean(b),e=0,f=b.length-1;for(;f>=0;f--)e+=a.pow(b[f]-d,2);return e/(b.length-(c?1:0))},stdev:function(b,c){return a.sqrt(i.variance(b,c))},meandev:function(b){var c=0,d=i.mean(b),e=b.length-1;for(;e>=0;e--)c+=a.abs(b[e]-d);return c/b.length},meddev:function(b){var c=0,d=i.median(b),e=b.length-1;for(;e>=0;e--)c+=a.abs(b[e]-d);return c/b.length},quartiles:function(b){var c=b.length,d=b.slice().sort(e);return[d[a.round(c/4)-1],d[a.round(c/2)-1],d[a.round(c*3/4)-1]]},covariance:function(a,b){var c=i.mean(a),d=i.mean(b),e=[],f=a.length,g=0;for(;g<f;g++)e[g]=(a[g]-c)*(b[g]-d);return i.sum(e)/f},corrcoeff:function(a,b){return i.covariance(a,b)/i.stdev(a,1)/i.stdev(b,1)}}),function(a){for(var b=0;b<a.length;b++)(function(a){i.fn[a]=function(b,c){var d=[],e=0,f=this;h(b)&&(c=b,b=!1);if(c){setTimeout(function(){c.call(f,i.fn[a].call(f,b))},15);return this}if(this.length>1){f=b===!0?this:this.transpose();for(;e<f.length;e++)d[e]=i[a](f[e]);return b===!0?i[a](d):d}return i[a](this[0])}})(a[b])}("sum sumsqrd sumsqerr product min max mean geomean median mode range variance stdev meandev meddev quartiles".split(" ")),function(a){for(var b=0;b<a.length;b++)(function(a){i.fn[a]=function(b){var c=this,d;if(b){setTimeout(function(){b.call(c,i.fn[a].call(c))},15);return this}d=i[a](this);return g(d)?i(d):d}})(a[b])}("transpose clear norm symmetric".split(" ")),function(a){for(var b=0;b<a.length;b++)(function(a){i.fn[a]=function(b,c){var d=this;if(c){setTimeout(function(){c.call(d,i.fn[a].call(d,b))},15);return this}return i(i[a](this,b))}})(a[b])}("add divide multiply subtract dot pow abs angle".split(" ")),function(a){for(var b=0;b<a.length;b++)(function(a){i.fn[a]=function(){return i(i[a].apply(null,arguments))}})(a[b])}("create zeros ones rand identity".split(" ")),i.extend(i.fn,{rows:function(){return this.length||1},cols:function(){return this[0].length||1},dimensions:function(){return{rows:this.rows(),cols:this.cols()}},row:function(a){return i(this[a])},col:function(a){var b=[],c=0;for(;c<this.length;c++)b[c]=[this[c][a]];return i(b)},diag:function(){var a=0,b=this.rows(),c=[];for(;a<b;a++)c[a]=[this[a][a]];return i(c)},antidiag:function(){var a=this.rows()-1,b=[],c=0;for(;a>=0;a--,c++)b[c]=[this[c][a]];return i(b)},map:function(a,b){return i(i.map(this,a,b))},alter:function(a){i.alter(this,a);return this}});return i}(Math),function(a,b){(function(b){for(var c=0;c<b.length;c++)(function(b){a[b]=function(a,b,c){if(!(this instanceof arguments.callee))return new arguments.callee(a,b,c);this._a=a,this._b=b,this._c=c;return this},a.fn[b]=function(c,d,e){var f=a[b](c,d,e);f.data=this;return f},a[b].prototype.sample=function(c){var d=this._a,e=this._b,f=this._c;return c?a.alter(c,function(){return a[b].sample(d,e,f)}):a[b].sample(d,e,f)},function(c){for(var d=0;d<c.length;d++)(function(c){a[b].prototype[c]=function(d){var e=this._a,f=this._b,g=this._c;if(isNaN(d))return a.fn.map.call(this.data,function(d){return a[b][c](d,e,f,g)});return a[b][c](d,e,f,g)}})(c[d])}("pdf cdf inv".split(" ")),function(c){for(var d=0;d<c.length;d++)(function(c){a[b].prototype[c]=function(){return a[b][c](this._a,this._b,this._c)}})(c[d])}("mean median mode variance".split(" "))})(b[c])})("beta centralF cauchy chisquare exponential gamma invgamma kumaraswamy lognormal normal pareto studentt weibull uniform  binomial negbin hypgeom poisson triangular".split(" ")),a.extend(a.beta,{pdf:function(c,d,e){return c>1||c<0?0:b.pow(c,d-1)*b.pow(1-c,e-1)/a.betafn(d,e)},cdf:function(b,c,d){return b>1||b<0?(b>1)*1:a.incompleteBeta(b,c,d)},inv:function(b,c,d){return a.incompleteBetaInv(b,c,d)},mean:function(a,b){return a/(a+b)},median:function(a,b){},mode:function(a,c){return a*c/(b.pow(a+c,2)*(a+c+1))},sample:function(b,c){var d=a.randg(b);return d/(d+a.randg(c))},variance:function(a,c){return a*c/(b.pow(a+c,2)*(a+c+1))}}),a.extend(a.centralF,{pdf:function(c,d,e){return c>=0?b.sqrt(b.pow(d*c,d)*b.pow(e,e)/b.pow(d*c+e,d+e))/(c*a.betafn(d/2,e/2)):undefined},cdf:function(b,c,d){return a.incompleteBeta(c*b/(c*b+d),c/2,d/2)},inv:function(b,c,d){return d/(c*(1/a.incompleteBetaInv(b,c/2,d/2)-1))},mean:function(a,b){return b>2?b/(b-2):undefined},mode:function(a,b){return a>2?b*(a-2)/(a*(b+2)):undefined},sample:function(b,c){var d=a.randg(b/2)*2,e=a.randg(c/2)*2;return d/b/(e/c)},variance:function(a,b){return b>4?2*b*b*(a+b-2)/(a*(b-2)*(b-2)*(b-4)):undefined}}),a.extend(a.cauchy,{pdf:function(a,c,d){return d/(b.pow(a-c,2)+b.pow(d,2))/b.PI},cdf:function(a,c,d){return b.atan((a-c)/d)/b.PI+.5},inv:function(a,c,d){return c+d*b.tan(b.PI*(a-.5))},median:function(a,b){return a},mode:function(a,b){return a},sample:function(c,d){return a.randn()*b.sqrt(1/(2*a.randg(.5)))*d+c}}),a.extend(a.chisquare,{pdf:function(c,d){return b.exp((d/2-1)*b.log(c)-c/2-d/2*b.log(2)-a.gammaln(d/2))},cdf:function(b,c){return a.gammap(c/2,b/2)},inv:function(b,c){return 2*a.gammapinv(b,.5*c)},mean:function(a){return a},median:function(a){return a*b.pow(1-2/(9*a),3)},mode:function(a){return a-2>0?a-2:0},sample:function(b){return a.randg(b/2)*2},variance:function(a){return 2*a}}),a.extend(a.exponential,{pdf:function(a,c){return a<0?0:c*b.exp(-c*a)},cdf:function(a,c){return a<0?0:1-b.exp(-c*a)},inv:function(a,c){return-b.log(1-a)/c},mean:function(a){return 1/a},median:function(a){return 1/a*b.log(2)},mode:function(a){return 0},sample:function(a){return-1/a*b.log(b.random())},variance:function(a){return b.pow(a,-2)}}),a.extend(a.gamma,{pdf:function(c,d,e){return b.exp((d-1)*b.log(c)-c/e-a.gammaln(d)-d*b.log(e))},cdf:function(b,c,d){return a.gammap(c,b/d)},inv:function(b,c,d){return a.gammapinv(b,c)*d},mean:function(a,b){return a*b},mode:function(a,b){if(a>1)return(a-1)*b;return undefined},sample:function(b,c){return a.randg(b)*c},variance:function(a,b){return a*b*b}}),a.extend(a.invgamma,{pdf:function(c,d,e){return b.exp(-(d+1)*b.log(c)-e/c-a.gammaln(d)+d*b.log(e))},cdf:function(b,c,d){return 1-a.gammap(c,d/b)},inv:function(b,c,d){return d/a.gammapinv(1-b,c)},mean:function(a,b){return a>1?b/(a-1):undefined},mode:function(a,b){return b/(a+1)},sample:function(b,c){return c/a.randg(b)},variance:function(a,b){return a>2?b*b/((a-1)*(a-1)*(a-2)):undefined}}),a.extend(a.kumaraswamy,{pdf:function(a,c,d){return b.exp(b.log(c)+b.log(d)+(c-1)*b.log(a)+(d-1)*b.log(1-b.pow(a,c)))},cdf:function(a,c,d){return 1-b.pow(1-b.pow(a,c),d)},mean:function(b,c){return c*a.gammafn(1+1/b)*a.gammafn(c)/a.gammafn(1+1/b+c)},median:function(a,c){return b.pow(1-b.pow(2,-1/c),1/a)},mode:function(a,c){return a>=1&&c>=1&&a!==1&&c!==1?b.pow((a-1)/(a*c-1),1/a):undefined},variance:function(a,b){}}),a.extend(a.lognormal,{pdf:function(a,c,d){return b.exp(-b.log(a)-.5*b.log(2*b.PI)-b.log(d)-b.pow(b.log(a)-c,2)/(2*d*d))},cdf:function(c,d,e){return.5+.5*a.erf((b.log(c)-d)/b.sqrt(2*e*e))},inv:function(c,d,e){return b.exp(-1.4142135623730951*e*a.erfcinv(2*c)+d)},mean:function(a,c){return b.exp(a+c*c/2)},median:function(a,c){return b.exp(a)},mode:function(a,c){return b.exp(a-c*c)},sample:function(c,d){return b.exp(a.randn()*d+c)},variance:function(a,c){return(b.exp(c*c)-1)*b.exp(2*a+c*c)}}),a.extend(a.normal,{pdf:function(a,c,d){return b.exp(-0.5*b.log(2*b.PI)-b.log(d)-b.pow(a-c,2)/(2*d*d))},cdf:function(c,d,e){return.5*(1+a.erf((c-d)/b.sqrt(2*e*e)))},inv:function(b,c,d){return-1.4142135623730951*d*a.erfcinv(2*b)+c},mean:function(a,b){return a},median:function(a,b){return a},mode:function(a,b){return a},sample:function(b,c){return a.randn()*c+b},variance:function(a,b){return b*b}}),a.extend(a.pareto,{pdf:function(a,c,d){return a>c?d*b.pow(c,d)/b.pow(a,d+1):undefined},cdf:function(a,c,d){return 1-b.pow(c/a,d)},mean:function(a,c){return c>1?c*b.pow(a,c)/(c-1):undefined},median:function(a,c){return a*c*b.SQRT2},mode:function(a,b){return a},variance:function(a,c){return c>2?a*a*c/(b.pow(c-1,2)*(c-2)):undefined}}),a.extend(a.studentt,{pdf:function(c,d){return a.gammafn((d+1)/2)/(b.sqrt(d*b.PI)*a.gammafn(d/2))*b.pow(1+c*c/d,-((d+1)/2))},cdf:function(c,d){var e=d/2;return a.incompleteBeta((c+b.sqrt(c*c+d))/(2*b.sqrt(c*c+d)),e,e)},inv:function(c,d){var e=a.incompleteBetaInv(2*b.min(c,1-c),.5*d,.5);e=b.sqrt(d*(1-e)/e);return c>0?e:-e},mean:function(a){return a>1?0:undefined},median:function(a){return 0},mode:function(a){return 0},sample:function(c){return a.randn()*b.sqrt(c/(2*a.randg(c/2)))},variance:function(a){return a>2?a/(a-2):a>1?Infinity:undefined}}),a.extend(a.weibull,{pdf:function(a,c,d){return a<0?0:d/c*b.pow(a/c,d-1)*b.exp(-b.pow(a/c,d))},cdf:function(a,c,d){return a<0?0:1-b.exp(-b.pow(a/c,d))},inv:function(a,c,d){return c*b.pow(-b.log(1-a),1/d)},mean:function(b,c){return b*a.gammafn(1+1/c)},median:function(a,c){return a*b.pow(b.log(2),1/c)},mode:function(a,c){return c>1?a*b.pow((c-1)/c,1/c):undefined},sample:function(a,c){return a*b.pow(-b.log(b.random()),1/c)},variance:function(c,d){return c*c*a.gammafn(1+2/d)-b.pow(this.mean(c,d),2)}}),a.extend(a.uniform,{pdf:function(a,b,c){return a<b||a>c?0:1/(c-b)},cdf:function(a,b,c){if(a<b)return 0;if(a<c)return(a-b)/(c-b);return 1},mean:function(a,b){return.5*(a+b)},median:function(b,c){return a.mean(b,c)},mode:function(a,b){},sample:function(a,c){return a/2+c/2+(c/2-a/2)*(2*b.random()-1)},variance:function(a,c){return b.pow(c-a,2)/12}}),a.extend(a.binomial,{pdf:function(c,d,e){return e===0||e===1?d*e===c?1:0:a.combination(d,c)*b.pow(e,c)*b.pow(1-e,d-c)},cdf:function(b,c,d){var e=[],f=0;if(b<0)return 0;if(b<c){for(;f<=b;f++)e[f]=a.binomial.pdf(f,c,d);return a.sum(e)}return 1}}),a.extend(a.negbin,{pdf:function(c,d,e){return c!==c|0?!1:c<0?0:a.combination(c+d-1,c)*b.pow(1-e,d)*b.pow(e,c)},cdf:function(b,c,d){var e=0,f=0;if(b<0)return 0;for(;f<=b;f++)e+=a.negbin.pdf(f,c,d);return e}}),a.extend(a.hypgeom,{pdf:function(b,c,d,e){return b!==b|0?!1:b<0?0:a.combination(d,b)*a.combination(c-d,e-b)/a.combination(c,e)},cdf:function(b,c,d,e){var f=0,g=0;if(b<0)return 0;for(;g<=b;g++)f+=a.hypgeom.pdf(g,c,d,e);return f}}),a.extend(a.poisson,{pdf:function(c,d){return b.pow(d,c)*b.exp(-d)/a.factorial(c)},cdf:function(b,c){var d=[],e=0;if(b<0)return 0;for(;e<=b;e++)d.push(a.poisson.pdf(e,c));return a.sum(d)},mean:function(a){return a},variance:function(a){return a},sample:function(a){var c=1,d=0,e=b.exp(-a);do d++,c*=b.random();while(c>e);return d-1}}),a.extend(a.triangular,{pdf:function(a,b,c,d){return c<=b||d<b||d>c?undefined:a<b||a>c?0:a<=d?2*(a-b)/((c-b)*(d-b)):2*(c-a)/((c-b)*(c-d))},cdf:function(a,c,d,e){if(d<=c||e<c||e>d)return undefined;if(a<c)return 0;if(a<=e)return b.pow(a-c,2)/((d-c)*(e-c));return 1-b.pow(d-a,2)/((d-c)*(d-e))},mean:function(a,b,c){return(a+b+c)/3},median:function(a,c,d){if(d<=(a+c)/2)return c-b.sqrt((c-a)*(c-d))/b.sqrt(2);if(d>(a+c)/2)return a+b.sqrt((c-a)*(d-a))/b.sqrt(2)},mode:function(a,b,c){return c},sample:function(a,c,d){var e=b.random();return e<(d-a)/(c-a)?a+b.sqrt(e*(c-a)*(d-a)):c-b.sqrt((1-e)*(c-a)*(c-d))},variance:function(a,b,c){return(a*a+b*b+c*c-a*b-a*c-b*c)/18}})}(this.jStat,Math),function(a,b){function c(a,c,d){var e=1e-30,f=1,g,h,i,j,k,l,m,n,o;m=c+d,o=c+1,n=c-1,i=1,j=1-m*a/o,b.abs(j)<e&&(j=e),j=1/j,l=j;for(;f<=100;f++){g=2*f,h=f*(d-f)*a/((n+g)*(c+g)),j=1+h*j,b.abs(j)<e&&(j=e),i=1+h/i,b.abs(i)<e&&(i=e),j=1/j,l*=j*i,h=-(c+f)*(m+f)*a/((c+g)*(o+g)),j=1+h*j,b.abs(j)<e&&(j=e),i=1+h/i,b.abs(i)<e&&(i=e),j=1/j,k=j*i,l*=k;if(b.abs(k-1)<3e-7)break}return l}a.extend({gammaln:function(a){var c=0,d=[76.18009172947146,-86.50532032941678,24.01409824083091,-1.231739572450155,.001208650973866179,-0.000005395239384953],e=1.000000000190015,f,g,h;h=(g=f=a)+5.5,h-=(f+.5)*b.log(h);for(;c<6;c++)e+=d[c]/++g;return b.log(2.5066282746310007*e/f)-h},gammafn:function(a){var c=[-1.716185138865495,24.76565080557592,-379.80425647094563,629.3311553128184,866.9662027904133,-31451.272968848367,-36144.413418691176,66456.14382024054],d=[-30.8402300119739,315.35062697960416,-1015.1563674902192,-3107.771671572311,22538.11842098015,4755.846277527881,-134659.9598649693,-115132.2596755535],e=!1,f=0,g=0,h=0,i=a,j,k,l,m,n,o;if(i<=0){m=i%1+3.6e-16;if(m)e=(i&1?-1:1)*b.PI/b.sin(b.PI*m),i=1-i;else return Infinity}l=i,i<1?k=i++:k=(i-=f=(i|0)-1)-1;for(j=0;j<8;++j)h=(h+c[j])*k,g=g*k+d[j];m=h/g+1;if(l<i)m/=l;else if(l>i)for(j=0;j<f;++j)m*=i,i++;e&&(m=e/m);return m},gammap:function(c,d){var e=a.gammaln(c),f=a.gammafn(c),g=c,h=1/c,i=h,j=d+1-c,k=1/1e-30,l=1/j,m=l,n=1,o=c>=1?c:1/c,p=-~(b.log(o)*8.5+c*.4+17),q,r;if(d<0||c<=0)return NaN;if(d<c+1){for(;n<=p;n++)h+=i*=d/++g;r=h*b.exp(-d+c*b.log(d)-e)}else{for(;n<=p;n++)q=-n*(n-c),j+=2,l=q*l+j,k=j+q/k,l=1/l,m*=l*k;r=1-m*b.exp(-d+c*b.log(d)-e)}return r*f/a.gammafn(c)},factorialln:function(b){return b<0?NaN:a.gammaln(b+1)},factorial:function(b){return b<0?NaN:a.gammafn(b+1)},combination:function(c,d){return c>170||d>170?b.exp(a.combinationln(c,d)):a.factorial(c)/a.factorial(d)/a.factorial(c-d)},combinationln:function(b,c){return a.factorialln(b)-a.factorialln(c)-a.factorialln(b-c)},permutation:function(b,c){return a.factorial(b)/a.factorial(b-c)},betafn:function(c,d){if(c<=0||d<=0)return undefined;return c+d>170?b.exp(a.betaln(c,d)):a.gammafn(c)*a.gammafn(d)/a.gammafn(c+d)},betaln:function(b,c){return a.gammaln(b)+a.gammaln(c)-a.gammaln(b+c)},gammapinv:function(c,d){var e=0,f=d-1,g=1e-8,h=a.gammaln(d),i,j,k,l,m,n,o;if(c>=1)return b.max(100,d+100*b.sqrt(d));if(c<=0)return 0;d>1?(n=b.log(f),o=b.exp(f*(n-1)-h),m=c<.5?c:1-c,k=b.sqrt(-2*b.log(m)),i=(2.30753+k*.27061)/(1+k*(.99229+k*.04481))-k,c<.5&&(i=-i),i=b.max(.001,d*b.pow(1-1/(9*d)-i/(3*b.sqrt(d)),3))):(k=1-d*(.253+d*.12),c<k?i=b.pow(c/k,1/d):i=1-b.log(1-(c-k)/(1-k)));for(;e<12;e++){if(i<=0)return 0;j=a.gammap(d,i)-c,d>1?k=o*b.exp(-(i-f)+f*(b.log(i)-n)):k=b.exp(-i+f*b.log(i)-h),l=j/k,i-=k=l/(1-.5*b.min(1,l*((d-1)/i-1))),i<=0&&(i=.5*(i+k));if(b.abs(k)<g*i)break}return i},erf:function(a){var c=[-1.3026537197817094,.6419697923564902,.019476473204185836,-0.00956151478680863,-0.000946595344482036,.000366839497852761,42523324806907e-18,-0.000020278578112534,-0.000001624290004647,130365583558e-17,1.5626441722e-8,-8.5238095915e-8,6.529054439e-9,5.059343495e-9,-9.91364156e-10,-2.27365122e-10,9.6467911e-11,2.394038e-12,-6.886027e-12,8.94487e-13,3.13092e-13,-1.12708e-13,3.81e-16,7.106e-15,-1.523e-15,-9.4e-17,1.21e-16,-2.8e-17],d=c.length-1,e=!1,f=0,g=0,h,i,j,k;a<0&&(a=-a,e=!0),h=2/(2+a),i=4*h-2;for(;d>0;d--)j=f,f=i*f-g+c[d],g=j;k=h*b.exp(-a*a+.5*(c[0]+i*f)-g);return e?k-1:1-k},erfc:function(b){return 1-a.erf(b)},erfcinv:function(c){var d=0,e,f,g,h;if(c>=2)return-100;if(c<=0)return 100;h=c<1?c:2-c,g=b.sqrt(-2*b.log(h/2)),e=-0.70711*((2.30753+g*.27061)/(1+g*(.99229+g*.04481))-g);for(;d<2;d++)f=a.erfc(e)-h,e+=f/(1.1283791670955126*b.exp(-e*e)-e*f);return c<1?e:-e},incompleteBetaInv:function(c,d,e){var f=1e-8,g=d-1,h=e-1,i=0,j,k,l,m,n,o,p,q,r,s,t;if(c<=0)return 0;if(c>=1)return 1;d<1||e<1?(j=b.log(d/(d+e)),k=b.log(e/(d+e)),m=b.exp(d*j)/d,n=b.exp(e*k)/e,s=m+n,c<m/s?p=b.pow(d*s*c,1/d):p=1-b.pow(e*s*(1-c),1/e)):(l=c<.5?c:1-c,m=b.sqrt(-2*b.log(l)),p=(2.30753+m*.27061)/(1+m*(.99229+m*.04481))-m,c<.5&&(p=-p),q=(p*p-3)/6,r=2/(1/(2*d-1)+1/(2*e-1)),s=p*b.sqrt(q+r)/r-(1/(2*e-1)-1/(2*d-1))*(q+5/6-2/(3*r)),p=d/(d+e*b.exp(2*s))),t=-a.gammaln(d)-a.gammaln(e)+a.gammaln(d+e);for(;i<10;i++){if(p===0||p===1)return p;o=a.incompleteBeta(p,d,e)-c,m=b.exp(g*b.log(p)+h*b.log(1-p)+t),n=o/m,p-=m=n/(1-.5*b.min(1,n*(g/p-h/(1-p)))),p<=0&&(p=.5*(p+m)),p>=1&&(p=.5*(p+m+1));if(b.abs(m)<f*p&&i>0)break}return p},incompleteBeta:function(d,e,f){var g=d===0||d===1?0:b.exp(a.gammaln(e+f)-a.gammaln(e)-a.gammaln(f)+e*b.log(d)+f*b.log(1-d));if(d<0||d>1)return!1;if(d<(e+1)/(e+f+2))return g*c(d,e,f)/e;return 1-g*c(1-d,f,e)/f},randn:function(c,d){var e,f,g,h,i,j;d||(d=c);if(c){j=a.zeros(c,d),j.alter(function(){return a.randn()});return j}do e=b.random(),f=1.7156*(b.random()-.5),g=e-.449871,h=b.abs(f)+.386595,i=g*g+h*(.196*h-.25472*g);while(i>.27597&&(i>.27846||f*f>-4*b.log(e)*e*e));return f/e},randg:function(c,d,e){var f=c,g,h,i,j,k,l;e||(e=d),c||(c=1);if(d){l=a.zeros(d,e),l.alter(function(){return a.randg(c)});return l}c<1&&(c+=1),g=c-1/3,h=1/b.sqrt(9*g);do{do k=a.randn(),j=1+h*k;while(j<=0);j=j*j*j,i=b.random()}while(i>1-.331*b.pow(k,4)&&b.log(i)>.5*k*k+g*(1-j+b.log(j)));if(c==f)return g*j;do i=b.random();while(i===0);return b.pow(i,1/f)*g*j}}),function(b){for(var c=0;c<b.length;c++)(function(b){a.fn[b]=function(){return a(a.map(this,function(c){return a[b](c)}))}})(b[c])}("gammaln gammafn factorial factorialln".split(" "))}(this.jStat,Math),function(a,b){var c=Array.prototype.push;a.extend({augment:function(a,b){var d=a.slice();for(var e=0;e<d.length;e++)c.apply(d[e],b[e]);return d},inv:function(b){var c=b.length,d=b[0].length,e=a.identity(c,d),f=a.gauss_jordan(b,e),g=[],h=0,i;for(;h<c;h++){g[h]=[];for(i=d-1;i<f[0].length;i++)g[h][i-d]=f[h][i]}return g},gauss_elimination:function(c,d){var e=0,f=0,g=c.length,h=c[0].length,i=1,j=0,k=[],l,m,n,o;c=a.augment(c,d),l=c[0].length;for(;e<g;e++){m=c[e][e],f=e;for(o=e+1;o<h;o++)m<b.abs(c[o][e])&&(m=c[o][e],f=o);if(f!=e)for(o=0;o<l;o++)n=c[e][o],c[e][o]=c[f][o],c[f][o]=n;for(f=e+1;f<g;f++){i=c[f][e]/c[e][e];for(o=e;o<l;o++)c[f][o]=c[f][o]-i*c[e][o]}}for(e=g-1;e>=0;e--){j=0;for(f=e+1;f<=g-1;f++)j=k[f]*c[e][f];k[e]=(c[e][l-1]-j)/c[e][e]}return k},gauss_jordan:function(c,d){var e=0,f=0,g=c.length,h=c[0].length,i=1,j=0,k=[],l,m,n,o;c=a.augment(c,d),n=c[0].length;for(;e<g;e++){m=c[e][e],f=e;for(o=e+1;o<h;o++)m<b.abs(c[o][e])&&(m=c[o][e],f=o);if(f!=e)for(;o<n;o++)l=c[e][o],c[e][o]=c[f][o],c[f][o]=l;for(f=0;f<g;f++)if(e!=f){i=c[f][e]/c[e][e];for(o=e;o<n;o++)c[f][o]=c[f][o]-i*c[e][o]}}for(e=0;e<g;e++){i=c[e][e];for(o=0;o<n;o++)c[e][o]=c[e][o]/i}return c},lu:function(a,b){},cholesky:function(a,b){},gauss_jacobi:function(c,d,e,f){var g=0,h=0,i=c.length,j=[],k=[],l=[],m,n,o,p;for(;g<i;g++){j[g]=[],k[g]=[],l[g]=[];for(h=0;h<i;h++)g>h?(j[g][h]=c[g][h],k[g][h]=l[g][h]=0):g<h?(k[g][h]=c[g][h],j[g][h]=l[g][h]=0):(l[g][h]=c[g][h],j[g][h]=k[g][h]=0)}o=a.multiply(a.multiply(a.inv(l),a.add(j,k)),-1),n=a.multiply(a.inv(l),d),m=e,p=a.add(a.multiply(o,e),n),g=2;while(b.abs(a.norm(a.subtract(p,m)))>f)m=p,p=a.add(a.multiply(o,m),n),g++;return p},gauss_seidel:function(c,d,e,f){var g=0,h=c.length,i=[],j=[],k=[],l,m,n,o,p;for(;g<h;g++){i[g]=[],j[g]=[],k[g]=[];for(l=0;l<h;l++)g>l?(i[g][l]=c[g][l],j[g][l]=k[g][l]=0):g<l?(j[g][l]=c[g][l],i[g][l]=k[g][l]=0):(k[g][l]=c[g][l],i[g][l]=j[g][l]=0)}o=a.multiply(a.multiply(a.inv(a.add(k,i)),j),-1),n=a.multiply(a.inv(a.add(k,i)),d),m=e,p=a.add(a.multiply(o,e),n),g=2;while(b.abs(a.norm(a.subtract(p,m)))>f)m=p,p=a.add(a.multiply(o,m),n),g=g+1;return p},SOR:function(c,d,e,f,g){var h=0,i=c.length,j=[],k=[],l=[],m,n,o,p,q;for(;h<i;h++){j[h]=[],k[h]=[],l[h]=[];for(m=0;m<i;m++)h>m?(j[h][m]=c[h][m],k[h][m]=l[h][m]=0):h<m?(k[h][m]=c[h][m],j[h][m]=l[h][m]=0):(l[h][m]=c[h][m],j[h][m]=k[h][m]=0)}p=a.multiply(a.inv(a.add(l,a.multiply(j,g))),a.subtract(a.multiply(l,1-g),a.multiply(k,g))),o=a.multiply(a.multiply(a.inv(a.add(l,a.multiply(j,g))),d),g),n=e,q=a.add(a.multiply(p,e),o),h=2;while(b.abs(a.norm(a.subtract(q,n)))>f)n=q,q=a.add(a.multiply(p,n),o),h++;return q},householder:function(c){var d=c.length,e=c[0].length,f=0,g=[],h=[],i,j,k,l,m;for(;f<d-1;f++){i=0;for(l=f+1;l<e;l++)i+=c[l][f]*c[l][f];m=c[f+1][f]>0?-1:1,i=m*b.sqrt(i),j=b.sqrt((i*i-c[f+1][f]*i)/2),g=a.zeros(d,1),g[f+1][0]=(c[f+1][f]-i)/(2*j);for(k=f+2;k<d;k++)g[k][0]=c[k][f]/(2*j);h=a.subtract(a.identity(d,e),a.multiply(a.multiply(g,a.transpose(g)),2)),c=a.multiply(h,a.multiply(c,h))}return c},QR:function(c,d){var e=c.length,f=c[0].length,g=0,h=[],i=[],j=[],k,l,m,n,o,p;for(;g<e-1;g++){l=0;for(k=g+1;k<f;k++)l+=c[k][g]*c[k][g];o=c[g+1][g]>0?-1:1,l=o*b.sqrt(l),m=b.sqrt((l*l-c[g+1][g]*l)/2),h=a.zeros(e,1),h[g+1][0]=(c[g+1][g]-l)/(2*m);for(n=g+2;n<e;n++)h[n][0]=c[n][g]/(2*m);i=a.subtract(a.identity(e,f),a.multiply(a.multiply(h,a.transpose(h)),2)),c=a.multiply(i,c),d=a.multiply(i,d)}for(g=e-1;g>=0;g--){p=0;for(k=g+1;k<=f-1;k++)p=j[k]*c[g][k];j[g]=d[g][0]/c[g][g]}return j},jacobi:function(c){var d=1,e=0,f=c.length,g=a.identity(f,f),h=[],i,j,k,l,m,n,o,p;while(d===1){e++,n=c[0][1],l=0,m=1;for(j=0;j<f;j++)for(k=0;k<f;k++)j!=k&&n<b.abs(c[j][k])&&(n=b.abs(c[j][k]),l=j,m=k);c[l][l]===c[m][m]?o=c[l][m]>0?b.PI/4:-b.PI/4:o=b.atan(2*c[l][m]/(c[l][l]-c[m][m]))/2,p=a.identity(f,f),p[l][l]=b.cos(o),p[l][m]=-b.sin(o),p[m][l]=b.sin(o),p[m][m]=b.cos(o),g=a.multiply(g,p),i=a.multiply(a.multiply(a.inv(p),c),p),c=i,d=0;for(j=1;j<f;j++)for(k=1;k<f;k++)j!=k&&b.abs(c[j][k])>.001&&(d=1)}for(j=0;j<f;j++)h.push(c[j][j]);return[g,h]},rungekutta:function(a,b,c,d,e,f){var g,h,i,j,k;if(f===2)while(d<=c)g=b*a(d,e),h=b*a(d+b,e+g),i=e+(g+h)/2,e=i,d=d+b;if(f===4)while(d<=c)g=b*a(d,e),h=b*a(d+b/2,e+g/2),j=b*a(d+b/2,e+h/2),k=b*a(d+b,e+j),i=e+(g+2*h+2*j+k)/6,e=i,d=d+b;return e},romberg:function(a,c,d,e){var f=0,g=(d-c)/2,h=[],i=[],j=[],k,l,m,n,o,p;while(f<e/2){o=a(c);for(m=c,n=0;m<=d;m=m+g,n++)h[n]=m;k=h.length;for(m=1;m<k-1;m++)o+=(m%2!==0?4:2)*a(h[m]);o=g/3*(o+a(d)),j[f]=o,g/=2,f++}l=j.length,k=1;while(l!==1){for(m=0;m<l-1;m++)i[m]=(b.pow(4,k)*j[m+1]-j[m])/(b.pow(4,k)-1);l=i.length,j=i,i=[],k++}return j},richardson:function(a,c,d,e){function f(a,b){var c=0,d=a.length,e;for(;c<d;c++)a[c]===b&&(e=c);return e}var g=a.length,h=b.abs(d-a[f(a,d)+1]),i=0,j=[],k=[],l,m,n,o,p;while(e>=h)l=f(a,d+e),m=f(a,d),j[i]=(c[l]-2*c[m]+c[2*m-l])/(e*e),e/=2,i++;o=j.length,n=1;while(o!=1){for(p=0;p<o-1;p++)k[p]=(b.pow(4,n)*j[p+1]-j[p])/(b.pow(4,n)-1);o=k.length,j=k,k=[],n++}return j},simpson:function(a,b,c,d){var e=(c-b)/d,f=a(b),g=[],h=b,i=0,j=1,k;for(;h<=c;h=h+e,i++)g[i]=h;k=g.length;for(;j<k-1;j++)f+=(j%2!==0?4:2)*a(g[j]);return e/3*(f+a(c))},hermite:function(a,b,c,d){var e=a.length,f=0,g=0,h=[],i=[],j=[],k=[],l;for(;g<e;g++){h[g]=1;for(l=0;l<e;l++)g!=l&&(h[g]*=(d-a[l])/(a[g]-a[l]));i[g]=0;for(l=0;l<e;l++)g!=l&&(i[g]+=1/(a[g]-a[l]));j[g]=(1-2*(d-a[g])*i[g])*h[g]*h[g],k[g]=(d-a[g])*h[g]*h[g],f+=j[g]*b[g]+k[g]*c[g]}return f},lagrange:function(a,b,c){var d=0,e=0,f,g,h=a.length;for(;e<h;e++){g=b[e];for(f=0;f<h;f++)e!=f&&(g*=(c-a[f])/(a[e]-a[f]));d+=g}return d},cubic_spline:function(b,c,d){var e=b.length,f=0,g,h=[],i=[],j=[],k=[],l=[],m=[],n=[];for(;f<e-1;f++)l[f]=b[f+1]-b[f];j[0]=0;for(f=1;f<e-1;f++)j[f]=3/l[f]*(c[f+1]-c[f])-3/l[f-1]*(c[f]-c[f-1]);for(f=1;f<e-1;f++)h[f]=[],i[f]=[],h[f][f-1]=l[f-1],h[f][f]=2*(l[f-1]+l[f]),h[f][f+1]=l[f],i[f][0]=j[f];k=a.multiply(a.inv(h),i);for(g=0;g<e-1;g++)m[g]=(c[g+1]-c[g])/l[g]-l[g]*(k[g+1][0]+2*k[g][0])/3,n[g]=(k[g+1][0]-k[g][0])/(3*l[g]);for(g=0;g<e;g++)if(b[g]>d)break;g-=1;return c[g]+(d-b[g])*m[g]+a.sq(d-b[g])*k[g]+(d-b[g])*a.sq(d-b[g])*n[g]},gauss_quadrature:function(){},PCA:function(b){var c=b.length,d=b[0].length,e=!1,f=0,g,h,i=[],j=[],k=[],l=[],m=[],n=[],o=[],p=[],q=[],r=[];for(f=0;f<c;f++)i[f]=a.sum(b[f])/d;for(f=0;f<d;f++){o[f]=[];for(g=0;g<c;g++)o[f][g]=b[g][f]-i[g]}o=a.transpose(o);for(f=0;f<c;f++){p[f]=[];for(g=0;g<c;g++)p[f][g]=a.dot([o[f]],[o[g]])/(d-1)}k=a.jacobi(p),q=k[0],j=k[1],r=a.transpose(q);for(f=0;f<j.length;f++)for(g=f;g<j.length;g++)j[f]<j[g]&&(h=j[f],j[f]=j[g],j[g]=h,l=r[f],r[f]=r[g],r[g]=l);n=a.transpose(o);for(f=0;f<c;f++){m[f]=[];for(g=0;g<n.length;g++)m[f][g]=a.dot([r[f]],[n[g]])}return[b,j,r,m]}})}(this.jStat,Math)