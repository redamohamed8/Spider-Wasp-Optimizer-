%_________________________________________________________________________%
%  Spider Wasp Optimizer (SWO) source codes demo 1.0               %
%                                                                         %
%  Developed in MATLAB R2019A                                      %
%                                                                         %
%  Author and programmer: Reda Mohamed (E-mail: redamoh@zu.edu.eg) & Mohamed Abdel-Basset (E-mail: mohamedbasset@ieee.org)                              %
%                                                                         %
%   Main paper: Abdel-Basset, M., Mohamed, R.                                    %
%               Spider Wasp Optimizer: A Novel Meta-Heuristic Optimization Algorithm,                         %
%               Artificial Intelligence Review, in press              %
%                  %
%                                                                         %
%_________________________________________________________________________%


% The Spider Wasp Optimizer
function [Best_score,Best_SW,Convergence_curve]=SWO(SearchAgents_no,Tmax,ub,lb,dim,fobj,fhd)

%%%%-------------------Definitions--------------------------%%
%%
Best_SW=zeros(1,dim); % A vector to include the best-so-far spider wasp(Solution) 
Best_score=inf; % A Scalar variable to include the best-so-far score
Convergence_curve=zeros(1,Tmax);

%%-------------------Controlling parameters--------------------------%%
%%
TR=0.3; %% Representing the trade-off probability between hunting and mating behaviours.
Cr=0.2; %% The Crossover probability
N_min=20; %% Representing the minimum population size.

%%---------------Initialization----------------------%%
%%
Positions=initialization(SearchAgents_no,dim,ub,lb); % Initialize the positions of spider wasps
t=0; %% Function evaluation counter 

%%---------------------Evaluation-----------------------%%
for i=1:SearchAgents_no
    %% Test suites of CEC-2014, CEC-2017, CEC-2020, and CEC-2022
    SW_Fit(i)=feval(fhd, Positions(i,:)',fobj);
    % Update the best-so-far solution
    if SW_Fit(i)<Best_score % Change this to > for maximization problem
       Best_score=SW_Fit(i); % Update the best-so-far score
       Best_SW=Positions(i,:); % Update te best-so-far solution
    end
end

% Main loop
while t<Tmax
    %%
    a=2-2*(t/Tmax); % a decreases linearly from 2 to 0
    a2=-1+-1*(t/Tmax); % a2 linearly dicreases from -1 to -2 to calculate l in Eq. (8)
    k=(1-t/Tmax); %% k decreases linearly from 1 to 0 (Eq. (13))
    JK=randperm(SearchAgents_no); %% A randomly-generated permutation of the search agent's indices 
    if rand<TR %% 3.2	Hunting and nesting behavior
       % Update the Position of search agents
       for i=1:SearchAgents_no
          r1=rand(); % r1 is a random number in [0,1]
          r2=rand(); % r2 is a random number in [0,1]
          r3=rand(); % r3 is a random number in [0,1]
          p = rand();  % p is a random number in [0,1]
          C=a*(2*r1-1);  % Eq. (11) in the paper
          l=(a2-1)*rand+1;   % The parameter in Eqs. (7) and (8)
          L=Levy(1); %% L is a Levy-based number 
          vc = unifrnd(-k,k,1,dim); %% The vector in Eq. (12)
          rn1=randn; %% rn1 is a normal distribution-based number 
          %%
          O_P=Positions(i,:); %% Storing the current position of the ith solution
          %%
          for j=1:size(Positions,2)
            if i<k*SearchAgents_no
               if p<(1-t/Tmax) %% 3.2.1	Searching stage (Exploration)
                   if r1<r2
                      m1=abs(rn1)*r1; %% Eq. (5)
                      Positions(i,j)=Positions(i,j)+m1*(Positions(JK(1),j)-Positions(JK(2),j)); %% Eq. (4)
                   else
                      B=1/(1+exp(l)); %% Eq. (8)
                      m2=B*cos(l*2*pi); %% Eq. (7) 
                      Positions(i,j)=Positions(JK(i),j)+m2*(lb(j)+rand*(ub(j)-lb(j))); %% Eq. (6)
                   end %% End If
               else %% 3.2.2	Following and escaping stage (exploration and exploitation)
                   if r1<r2
                      Positions(i,j)=Positions(i,j)+C*abs(2*rand*Positions(JK(3),j)-Positions(i,j)); %% Eq. (10)
                   else
                      Positions(i,j)=Positions((i),j).*vc(j); %% Eq. (12)
                   end %% End If
               end
             else
                 if r1<r2
                     Positions(i,j)=Best_SW(j)+cos(2*l*pi)*(Best_SW(j)-Positions(i,j));      % Eq. (16)
                 else
                     Positions(i,j)=Positions(JK(1),j)+r3*abs(L)*(Positions(JK(1),j)-Positions(i,j))+(1-r3)*(rand>rand)*(Positions(JK(3),j)-Positions(JK(2),j));      % Eq. (17)
                 end %% End if
            end %% End if
          end %% End Inner If
          %% Return the search agents that exceed the search space's bounds
          for j=1:size(Positions,2)
              if  Positions(i,j)>ub(j)
                   Positions(i,j)=lb(j)+rand*(ub(j)-lb(j));
              elseif  Positions(i,j)<lb(j)
                   Positions(i,j)=lb(j)+rand*(ub(j)-lb(j));
              end
          end   
          SW_Fit1=feval(fhd, Positions(i,:)',fobj); %% The fitness value of the newly generated spider
          % Memory Saving and Updating the best-so-far solution
          if SW_Fit1<SW_Fit(i) % Change this to > for maximization problem
               SW_Fit(i)=SW_Fit1; % Update the local best fitness
               % Update the best-so-far solution
               if SW_Fit(i)<Best_score % Change this to > for maximization problem
                 Best_score=SW_Fit(i); % Update best-so-far fitness
                 Best_SW=Positions(i,:); % Update best-so-far position
               end
          else
               Positions(i,:)=O_P; %% Return the last best solution obtained by the ith solution
          end
          t=t+1;
          if t>Tmax
              break;
          end
          Convergence_curve(t)=Best_score;
       end %% Enter Outer For
       %% Mating behavior
    else     
       % Update the Position of search agents
       for i=1:SearchAgents_no
           l=(a2-1)*rand+1;    %% The parameter in Eqs. (7) and (8)
           SW_m=zeros(1,dim);  %% including the spider wasp male
           O_P=Positions(i,:); %% Storing the current position of the ith solution
         %% The Step sizes used to generate the male spider with a high quality    
           if SW_Fit(JK(1))<SW_Fit(i)  %Eq. (23)
              v1=Positions(JK(1),:)-Positions(i,:);  
           else
              v1=Positions(i,:)-Positions(JK(1),:);
           end
           if SW_Fit(JK(2))<SW_Fit(JK(3)) %Eq. (24)
              v2=Positions(JK(2),:)-Positions(JK(3),:);
           else
              v2=Positions(JK(3),:)-Positions(JK(2),:);
           end
           %%
           rn1=randn; %% rn1 is a normal distribution-based number 
           rn2=randn; %% rn1 is a normal distribution-based number 
           for j=1:size(Positions,2)
               SW_m(j)= Positions(i,j)+(exp(l))*abs(rn1)*v1(j)+(1-exp(l))*abs(rn2)*v2(j);      % Eq. (22)
               if(rand<Cr) %% Eq. (21)
                  Positions(i,j)=SW_m(j);
               end
           end
           %% Return the search agents that exceed the search space's bounds
           for j=1:size(Positions,2)
              if  Positions(i,j)>ub(j)
                   Positions(i,j)=lb(j)+rand*(ub(j)-lb(j));
              elseif  Positions(i,j)<lb(j)
                   Positions(i,j)=lb(j)+rand*(ub(j)-lb(j));
              end
           end   
           SW_Fit1=feval(fhd, Positions(i,:)',fobj);; %% The fitness value of the newly generated spider
           % Memory Saving and Updating the best-so-far solution
           if SW_Fit1<SW_Fit(i) % Change this to > for maximization problem
               SW_Fit(i)=SW_Fit1; % Update the local best fitness
               % Update the best-so-far solution
               if SW_Fit(i)<Best_score % Change this to > for maximization problem
                 Best_score=SW_Fit(i); % Update best-so-far fitness
                 Best_SW=Positions(i,:); % Update best-so-far position
               end
           else
               Positions(i,:)=O_P; %% Return the last best solution obtained by the ith solution
           end
           t=t+1;
           if t>Tmax
              break;
           end
           Convergence_curve(t)=Best_score;
       end %% End For
    end %% End If
    %% Population reduction %%
    SearchAgents_no=fix(N_min+(SearchAgents_no-N_min)*((Tmax-t)/Tmax)); %% Eq. (25)
end %% End While
Convergence_curve(t-1)=Best_score;
end

% Draw n Levy flight sample
function L=Levy(d)
beta=3/2;
sigma=(gamma(1+beta)*sin(pi*beta/2)/(gamma((1+beta)/2)*beta*2^((beta-1)/2)))^(1/beta);
u=randn(1,d)*sigma;
v=randn(1,d);
step=u./abs(v).^(1/beta);
L=0.05*step;
end

